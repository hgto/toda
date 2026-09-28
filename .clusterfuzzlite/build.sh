#!/bin/bash -eu

# Install toda so the fuzz targets can import it. There are no C extensions,
# so the default compiler flags do not matter.
pip3 install .

for fuzzer in $(find "$SRC/toda/fuzz" -name '*_fuzzer.py'); do
  fuzzer_basename=$(basename -s .py "$fuzzer")
  fuzzer_package="${fuzzer_basename}.pkg"

  # Bundle the target into a standalone executable so it keeps working
  # regardless of the Python environment that later runs it.
  pyinstaller --distpath "$OUT" --onefile --name "$fuzzer_package" "$fuzzer"

  # Atheris needs a wrapper with the LLVMFuzzerTestOneInput marker for libFuzzer
  # to recognize the binary as a fuzz target. This project is pure Python, so
  # no sanitizer library has to be preloaded.
  echo "#!/bin/sh
# LLVMFuzzerTestOneInput for fuzzer detection.
this_dir=\$(dirname \"\$0\")
\"\$this_dir/$fuzzer_package\" \"\$@\"" > "$OUT/$fuzzer_basename"
  chmod +x "$OUT/$fuzzer_basename"
done
