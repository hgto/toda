import contextlib
import io
import sys

import atheris

with atheris.instrument_imports():
    from toda.errors import ManifestError
    from toda.model import Manifest


def TestOneInput(data: bytes) -> None:
    manifest = Manifest()
    with contextlib.suppress(ManifestError):
        manifest._parse(io.StringIO(data.decode("utf-8", errors="replace")))


atheris.Setup(sys.argv, TestOneInput)
atheris.Fuzz()
