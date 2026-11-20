# sRGB display profile whose vcgt squeezes output into 16-235, for sinks that
# read RGB as limited range (USB-C to HDMI adapters drop the AVI infoframe).
import struct
import sys


def s15(x):
    return struct.pack(">i", round(x * 65536))


def xyz(x, y, z):
    return b"XYZ " + b"\0" * 4 + s15(x) + s15(y) + s15(z)


def srgb_eotf(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4


def curv():
    n = 1024
    return b"curv" + b"\0" * 4 + struct.pack(">I", n) + b"".join(
        struct.pack(">H", round(srgb_eotf(i / (n - 1)) * 65535)) for i in range(n)
    )


def desc(text):
    t = text.encode() + b"\0"
    return (
        b"desc" + b"\0" * 4 + struct.pack(">I", len(t)) + t
        + b"\0" * 8 + b"\0" * 3 + b"\0" * 67
    )


def vcgt():
    ramp = b"".join(
        struct.pack(">H", round((16 + i * 219 / 255) / 255 * 65535)) for i in range(256)
    )
    return b"vcgt" + b"\0" * 4 + struct.pack(">IHHH", 0, 3, 256, 2) + ramp * 3


trc = curv()
tags = [
    (b"desc", desc("sRGB, limited range 16-235")),
    (b"cprt", b"text" + b"\0" * 4 + b"No copyright\0"),
    (b"wtpt", xyz(0.9642, 1.0, 0.8249)),
    (b"rXYZ", xyz(0.4360747, 0.2225045, 0.0139322)),
    (b"gXYZ", xyz(0.3850649, 0.7168786, 0.0971045)),
    (b"bXYZ", xyz(0.1430804, 0.0606169, 0.7141733)),
    (b"rTRC", trc),
    (b"gTRC", trc),
    (b"bTRC", trc),
    (b"vcgt", vcgt()),
]

offset = 128 + 4 + 12 * len(tags)
table, data = b"", b""
for sig, body in tags:
    body += b"\0" * (-len(body) % 4)
    table += sig + struct.pack(">II", offset + len(data), len(body))
    data += body

size = offset + len(data)
header = (
    struct.pack(">I", size) + b"    " + struct.pack(">I", 0x02100000)
    + b"mntrRGB XYZ " + b"\0" * 12 + b"acsp" + b"\0" * 24
    + struct.pack(">I", 0) + s15(0.9642) + s15(1.0) + s15(0.8249) + b"\0" * 48
)
assert len(header) == 128
sys.stdout.buffer.write(header + struct.pack(">I", len(tags)) + table + data)
