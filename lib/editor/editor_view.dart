// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protex/common/navigation_service.dart';
import 'package:protex/common/templates.dart';
import 'package:protex/compiler/subprocess_runner.dart';
import 'package:protex/editor/home.dart';
import 'package:protex/editor/item_editor.dart';
import 'package:protex/editor/shortcut.dart';
import 'package:protex/editor/unsaved_changed_dialog.dart';
import 'package:protex/l10n/app_localizations.dart';
import 'package:protex/main.dart';
import 'package:protex/menu/menu_bar.dart';
import 'package:protex/menu/menu_entry.dart';
import 'package:protex/settings/settings_view.dart';
import 'package:protex/document/document.dart';
import 'package:protex/document/library.dart';

class EditorView extends StatefulWidget{
  const EditorView({super.key});

  static const routeName = '/';

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> with TickerProviderStateMixin {
  late TabController _tabController;

  late CompleteMenuBar menuBar;
  ShortcutRegistryEntry? _shortcutsEntry;

  bool showHome = false;

  @override
  void initState() {
    updateTabs();
    _tabController.addListener(() => setState(() {
      openDocs.updateIndex(_tabController.index);
    }));
    openDocs.addListener(() => setState(() {
      openDocs.updateIndex(_tabController.index);
      showHome = false;
      updateState();
    }));
    settingsController.addListener(() => setState(() {}));

    // Override the default macOS menu
    // TODO add menu parity
    if (Platform.isMacOS) {
      WidgetsBinding.instance.platformMenuDelegate.setMenus(<PlatformMenuItem>[
        PlatformMenu(
          label: l10n.file, 
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.about,
                  onSelected: () {
                    showAboutDialog(context: NavigationService.navigatorKey.currentContext!, applicationName: l10n.appName, applicationVersion: parsedPubspec.version?.canonicalizedVersion != null ? l10n.version(parsedPubspec.version!.canonicalizedVersion) : null);
                  },
                ),
              ]
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.quit,
                  onSelected: () async => await SystemNavigator.pop(animated: true),
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyQ,
                    meta: true
                  )
                )
              ]
            ),
          ]
        ),
        PlatformMenu(
          label: l10n.file, 
          menus: <PlatformMenuItem> [
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.newDoc,
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyN,
                    meta: true
                  ),
                  onSelected: () async => await newDoc(),
                ),
                PlatformMenuItem(
                  label: l10n.newTab,
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyN,
                    meta: true,
                    shift: true
                  ),
                  onSelected: () {
                    openDocs.add(Templates.newDoc());
                  },
                ),
              ]
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.open,
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyO,
                    meta: true
                  ),
                  onSelected: () => open(),
                ),
              ]
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.save,
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyS,
                    meta: true
                  ),
                  onSelected: () async => await save(),
                ),
                PlatformMenuItem(
                  label: l10n.saveAs,
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyS,
                    meta: true,
                    shift: true
                  ),
                  onSelected: () async => await save(saveAs: true),
                ),
                PlatformMenuItem(
                  label: l10n.export,
                  onSelected: () => log("export"),
                  shortcut: SingleActivator(LogicalKeyboardKey.keyE, shift: true, meta: true)
                ),
              ]
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: l10n.close,
                  onSelected: () async => await closeTab(),
                  shortcut: SingleActivator(LogicalKeyboardKey.keyW, meta: true)
                )
              ]
            )
          ]
        )
      ]);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _shortcutsEntry?.dispose();
  }

  void updateTabs() {
    int initialIndex() {
      try {
        return (openDocs.isNotEmpty && openDocs.length != _tabController.length) ? openDocs.length-1 : _tabController.index;
      } catch (e) {
        log("_tabController not yet initialized.", error: e);
        return 0;
      }
    }

    _tabController = TabController(
      length: openDocs.length, 
      vsync: this,
      initialIndex: initialIndex(),
      animationDuration: Duration(milliseconds: 250)
    ); // TODO find suitable PDF viewer to implement
  }

  void updateState() {
    setState(() {
      updateTabs();
    });
  }

  /// Open a new [Document] and add it to the [Library].
  /// 
  /// If a [Document] is open in the current tab, this will replace it with [Templates.newDoc]. If the current open [Document] is unsaved, the user will be prompted to save it.
  Future<void> newDoc() async {
    if (openDocs.isEmpty) {
      openDocs.add(Templates.newDoc(context: context));
    } else if (openDocs.length > _tabController.index && openDocs.documents[_tabController.index].saved) {
      openDocs.newDocument(_tabController.index);
    } else {
      await UnsavedChangedDialog(
        context: context,
        save: () => save().whenComplete(() => Navigator.pop(context)),
        approveAction: () {
          openDocs.newDocument(_tabController.index);
          Navigator.pop(context);
        },
      ).showDialog;
    }
  }

  /// Save a [Document] in the [Library].
  /// 
  /// Depending on how long the document takes to save, the user may see a [CircularProgressIndicator] in the [AppBar].
  /// 
  /// You may optionally specify if the "save as" file picker dialog should be shown.
  /// Example:
  /// ```dart
  /// await save(saveAs: true);
  /// ```
  Future<void> save({bool saveAs = false}) async {
    if (openDocs.isNotEmpty) {
      setState(() {
        openDocs.documents[_tabController.index].status.inProgress = true;
      });
      if (saveAs) openDocs.documents[_tabController.index].path = null;
      await openDocs.documents[_tabController.index].save(NavigationService.navigatorKey.currentContext!).whenComplete(() => setState(() {
        openDocs.documents[_tabController.index].status.inProgress = false;
      }));
    }
  }

  /// Open a [Document] and add it to the [Library].
  void open() async {
    openDocs.open(context);
  }

  /// Close a [Document] tab and remove it from the [Library].
  /// 
  /// If the [Document] is unsaved, the user will be prompted to save before closing the tab.
  /// 
  /// You may optionally specify the index of the document to be removed.
  /// Example:
  /// ```dart
  /// await closeTab(index: 3);
  /// ```
  /// 
  /// Without a specified index, the last tab will be closed.
  /// Example:
  /// ```dart
  /// await closeTab();
  /// ```
  Future<void> closeTab({int? index}) async {
    try {
      if (openDocs.isEmpty) {
        return;
      } else if (index != null && openDocs.documents[index].saved) {
        openDocs.removeAt(index);
      } else if (index == null && openDocs.isNotEmpty && openDocs.length > _tabController.index && openDocs.documents[_tabController.index].saved) {
        openDocs.removeAt(_tabController.index);
      } else {
        await UnsavedChangedDialog(
          context: context, 
          approveAction: () {
            openDocs.removeAt(index ?? _tabController.index);
            Navigator.pop(context);
          }, 
          save: () async => await save().whenComplete(() {
          Navigator.pop(context);
          openDocs.removeAt(_tabController.index);
        }),
        ).showDialog;
      }
    } catch (e) {
      log(error: e, "TabController failed to catch up with user actions");
    }
  }

  /// Builds a PDF from the PTeX document and shows a dialog if the build fails
  void makePdf({int? index}) async {
    if (openDocs.isNotEmpty) {
      Document doc = openDocs.documents[index ?? _tabController.index];
      doc.createCompiler(context);
      
      String? result = await doc.compile;
      if (result != null) {
        showAdaptiveDialog(context: context, builder: (context) {
          return AlertDialog.adaptive(
            title: Text(AppLocalizations.of(context)!.compileErrorDialogTitle),
            content: SingleChildScrollView(child: Text(result)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.dismiss))
            ],
          );
        });
      }
    }
  }

  /// Use the operating system's default file viewer to open a directory.
  void openLocation(String path) async {
    if (Platform.isWindows) {
      await subprocess(exec: "explorer.exe", args: [path]);
      return;
    } else if (Platform.isMacOS) {
      await subprocess(exec: "open", args: [path]);
      return;
    } else if (Platform.isLinux) {
      await subprocess(exec: "xdg-open", args: [path]);
      return;
    }
  }

  bool _dragging = false;

  @override
  Widget build(BuildContext context) { // TODO support tab dragging/rearranging

    List<MenuEntry> getMenus() {
      final List<MenuEntry> result = <MenuEntry>[
        MenuEntry(
          AppLocalizations.of(context)!.file,
          menuChildren: <MenuEntry>[
            MenuEntry(
              AppLocalizations.of(context)!.newDoc,
              shortcut: SingleActivator(LogicalKeyboardKey.keyN, control: true),
              onPressed: () async => await newDoc(),
            ),
            MenuEntry(
              AppLocalizations.of(context)!.newTab,
              shortcut: SingleActivator(LogicalKeyboardKey.keyN, control: true, shift: true),
              onPressed: () => openDocs.add(Templates.newDoc(context: context))
            ),
            MenuEntry(
              AppLocalizations.of(context)!.open,
              shortcut: SingleActivator(LogicalKeyboardKey.keyO, control: true),
              onPressed: () => open()
            ),
            MenuEntry(
              AppLocalizations.of(context)!.save,
              shortcut: SingleActivator(LogicalKeyboardKey.keyS, control: true),
              onPressed: () async => await save()
            ),
            MenuEntry(
              AppLocalizations.of(context)!.saveAs,
              shortcut: SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true),
              onPressed: () async => await save(saveAs: true)
            ),
            MenuEntry(
              AppLocalizations.of(context)!.export,
              shortcut: SingleActivator(LogicalKeyboardKey.keyE, control: true, shift: true),
              onPressed: () => log("export")
            ),
            MenuEntry(
              AppLocalizations.of(context)!.build,
              shortcut: SingleActivator(LogicalKeyboardKey.f5),
              onPressed: () async => makePdf()
            ),
            MenuEntry(
              AppLocalizations.of(context)!.close,
              shortcut: SingleActivator(LogicalKeyboardKey.keyW, control: true),
              onPressed: () async => await closeTab()
            ),
          ]
        ),
        MenuEntry(
          AppLocalizations.of(context)!.edit,
          menuChildren: <MenuEntry>[
            MenuEntry(
              AppLocalizations.of(context)!.prefs,
              shortcut: SingleActivator(LogicalKeyboardKey.comma, control: true),
              onPressed: () => Navigator.restorablePushNamed(context, SettingsView.routeName),
            ),
            MenuEntry(
              AppLocalizations.of(context)!.find,
              shortcut: SingleActivator(LogicalKeyboardKey.keyF, control: true),
              onPressed: () => log("find"),
            ),
            MenuEntry(
              AppLocalizations.of(context)!.replace,
              shortcut: SingleActivator(LogicalKeyboardKey.keyR, control: true),
              onPressed: () => log("replace"),
            ),
          ]
        ),
        MenuEntry(
          AppLocalizations.of(context)!.go,
          menuChildren: <MenuEntry>[
            MenuEntry(
              AppLocalizations.of(context)!.cacheLocation,
              onPressed: () async => openLocation((await getApplicationCacheDirectory()).path),
            ),
            MenuEntry(
              AppLocalizations.of(context)!.tempLocation,
              onPressed: () async => openLocation((await getTemporaryDirectory()).path),
            ),
          ]
        ),
        MenuEntry(
          AppLocalizations.of(context)!.view,
          menuChildren: <MenuEntry>[
            MenuEntry(
              AppLocalizations.of(context)!.showShortcuts,
              shortcut: SingleActivator(LogicalKeyboardKey.f1),
              onPressed: () async => await settingsController.updateShowShortcuts(!settingsController.showShortcuts),
            )
          ]
        ),
      ];

      _shortcutsEntry?.dispose();
      _shortcutsEntry = ShortcutRegistry.of(context).addAll(MenuEntry.shortcuts(result));
      return result;
    }
    menuBar = CompleteMenuBar(getMenus());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: List.generate(
            openDocs.length, 
            (int index) => GestureDetector(
              onTertiaryTapDown: (details) async => await closeTab(index: index),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [ 
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 12, right: 12),
                    child: Text(
                      openDocs.documents[index].title,
                      style: Theme.of(context).textTheme.labelLarge,
                    )
                  ),
                  TextButton(
                    onPressed: () async => await closeTab(index: index), 
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                    ),
                    child: Icon(Icons.close, opticalSize: Theme.of(context).textTheme.labelLarge?.fontSize,)
                  )
                ]
              )
            )
          )
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: (_tabController.index < openDocs.length && openDocs.documents[_tabController.index].status.saving) ? CircularProgressIndicator.adaptive() : (_tabController.index < openDocs.length && openDocs.documents[_tabController.index].status.building) ? CircularProgressIndicator.adaptive(value: openDocs.documents[_tabController.index].status.buildProgress,) : Text(AppLocalizations.of(context)!.statusReady)
          ),
          IconButton(
            onPressed: () async => openDocs.documents[_tabController.index].status.building ? openDocs.documents[_tabController.index].compiler!.stopEarly : makePdf(),
            icon: Icon((_tabController.index < openDocs.length && openDocs.documents[_tabController.index].status.building) ? Icons.stop : Icons.play_arrow)
          ),
          IconButton(
            onPressed: () => setState(() => showHome = !showHome), 
            icon: Icon(Icons.home, color: showHome ? Colors.white : null)
          ),
          IconButton(
            onPressed: () => openDocs.add(Templates.newDoc(context: context)), 
            icon: Icon(Icons.add)
          ),
          IconButton(
            onPressed: () => Navigator.restorablePushNamed(
              context,
              SettingsView.routeName
            ),
            icon: Icon(Icons.settings)
          )
        ],
      ),
      body: DropTarget(
        onDragEntered: (details) {
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (details) {
          setState(() {
            _dragging = false;
          });
        },
        onDragDone: (details) {
          openDocs.openAll(details.files);
        },
        child: SafeArea(
          child: Container(
            color: _dragging ? Theme.of(context).canvasColor.withAlpha(100) : null,
            child: Column(
              children: [
                if (openDocs.isEmpty || showHome) Flexible(
                  child: Padding(padding: EdgeInsets.all(16), child: Home()),
                ),
                if (openDocs.isNotEmpty && !showHome) Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: List.generate(
                      openDocs.length, 
                      (int index) => settingsController.showShortcuts 
                      ? Row(children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints.expand(width: 250),
                            child: Card(
                              child: ListView.builder(
                                itemCount: shortcuts.length,
                                itemBuilder: (context, index) {
                                  Widget? header;

                                  if (index == 0) {
                                    header = Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(shortcuts[index].category.name.toUpperCase(), style: Theme.of(context).textTheme.titleLarge)
                                    );
                                  } else if (index > 0 && shortcuts[index].category != shortcuts[index-1].category) {
                                    header = Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(shortcuts[index].category.name.toUpperCase(), style: Theme.of(context).textTheme.titleLarge)
                                    );
                                  }
                                  Shortcut shortcut = shortcuts[index];

                                  if (header != null) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        header,
                                        Padding(
                                          padding: EdgeInsets.all(12),
                                          child: RichText(text: TextSpan(text: "${shortcut.name}:\t\t", children: <TextSpan>[
                                            TextSpan(text: shortcut.shortCut, style: TextStyle(fontFamily: 'SourceCodePro'), recognizer: TapGestureRecognizer()..onTap = () async {
                                              await Clipboard.setData(ClipboardData(text: shortcut.shortCut)).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.copied))));
                                            })
                                          ]), softWrap: true, textAlign: TextAlign.justify,),
                                        )
                                      ]
                                    );
                                  }
                                  
                                  return Padding(
                                    padding: EdgeInsets.all(12),
                                    child: RichText(text: TextSpan(text: "${shortcut.name}:\t\t", children: <TextSpan>[
                                      TextSpan(text: shortcut.shortCut, style: TextStyle(fontFamily: 'SourceCodePro'), recognizer: TapGestureRecognizer()..onTap = () async {
                                        await Clipboard.setData(ClipboardData(text: shortcut.shortCut)).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.copied))));
                                      })
                                    ]), softWrap: true, textAlign: TextAlign.justify,),
                                  );
                                }
                              ),
                            ),
                          ),
                          Expanded(child: ItemEditor(openDocs.documents[index])), 
                        ],) 
                      : ItemEditor(openDocs.documents[index])
                    )
                  )
                ),
              ]
            )
          )
        ),
      ),
      bottomNavigationBar: menuBar,
    );
  }
}