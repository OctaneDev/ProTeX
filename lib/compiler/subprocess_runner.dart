import 'dart:io';

/// Run a process to completion and receive its results.
/// 
/// If the process cannot run, the function will return `null`.
Future<ProcessResult?> subprocess({required String exec, required List<String> args, String? wd}) async {
  try {
    late final ProcessResult result;
    if (Platform.isMacOS) {
      result = await Process.run(exec.toLowerCase().contains("tex") ? "/Library/TeX/texbin/$exec" : exec, args, runInShell: true, stderrEncoding: systemEncoding, stdoutEncoding: systemEncoding, workingDirectory: wd);
      //log([exec.toLowerCase().contains("tex") ? "/Library/TeX/texbin/$exec" : exec, args].toString());
    } else {
      result = await Process.run(exec, args, runInShell: true, stderrEncoding: systemEncoding, stdoutEncoding: systemEncoding, workingDirectory: wd);
    }
    //log(result.stderr.toString());
    return result;
  } catch (e) {
    return null;
  }
}