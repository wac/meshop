# bit count library
# bitcount(val) returns number of set bits in val

# import the function bitcount()

__bctable__={}
__bctable__[0]=0

__bitmaskCacheBits__=16
#bitmaskCache=int("1"*8,2)
bitmaskCache=int("1"*__bitmaskCacheBits__,2)
#bitmaskCache=int("1"*32,2)

def __bitcountCache__(v0):
    if v0 in __bctable__:
        return __bctable__[v0]

    c=0

# Recursive
# c=1+__bitcountCache__(v0 & (v0 - 1))

# Iterative
    v=v0
    while v:
        v &= v -1;
        c += 1;

# MIT Bitcount
#    uCount = v0 - ((v0 >> 1) & 033333333333) - ((v0 >> 2) & 011111111111);
#    c = ((uCount + (uCount >> 3)) & 030707070707) % 63;

    __bctable__[v0]=c
    return c

def bitcount(v):
    c=0
    while v:
        c += __bitcountCache__(v & bitmaskCache)
        v = v >> __bitmaskCacheBits__
    return c



