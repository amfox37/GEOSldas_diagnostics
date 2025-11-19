import struct

def read_tilecoord(fname):
    # Open file
    with open(fname, 'rb') as fid:
        # Read file header
        fmt_header = '>i'  # Integer format (big endian)
        n_tiles, = struct.unpack(fmt_header, fid.read(4))  # Unpack number of tiles
        print(f"Number of tiles: {n_tiles}")

        # Read tile information
        fmt_tile = '>ii'  # Two integers (big endian)
        tile_coord = []
        for i in range(n_tiles):
            tile = struct.unpack(fmt_tile, fid.read(8))  # Unpack tile coordinates
            tile_coord.append(tile)

    return tile_coord
