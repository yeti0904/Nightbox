# NightboxFS
NightboxFS is a custom file system designed for YETI-16 disks

## Boot record

| Offset | Size (bytes) | Meaning                                                               |
| 0x00   | 4            | This can be anything, should be used for jumping past the boot record | 
| 0x04   | 2            | Magic number, little endian 16-bit integer equal to 0x424E            |
| 0x06   | 2            | Number of sectors in filesystem                                       |
| 0x08   | 16           | Disk name                                                             |
| 0x18   | 488          | Boot code                                                             |

## Sector contents
| Offset | Size (bytes) | Meaning                                                               |
| 0x00   | 1            | Equal to the type of the sector                                       |
| 0x01   | 1            | Magic byte, equal to 0x4E                                             |

## Sector types
### 0x00 - File table

The base sector contents leave 510 bytes for the rest of the sector, so there's room for
2 entries with acceptable path lengths

Each entry is structured like this

| Offset | Size (bytes) | Meaning                                                               |
| 0x00   | 2            | First sector (0 if empty file)                                        |
| 0x02   | 253          | Path                                                                  |

## 0x01 - File fragment

| Offset | Size (bytes) | Meaning                                                               |
| 0x02   | 2            | Next sector (0 if end of file)                                        |
| 0x04   | 2            | Contents length (only used in last sector)                            |
| 0x06   | 506          | Sector contents                                                       |
