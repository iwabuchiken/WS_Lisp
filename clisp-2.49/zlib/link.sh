${MAKE-make} clisp-module \
  CC="${CC}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" \
  CLISP_LINKKIT="$absolute_linkkitdir" CLISP="${CLISP}"
NEW_FILES="zlib.o"
NEW_LIBS="${NEW_FILES} -lz"
NEW_MODULES="zlib"
TO_LOAD='zlib'
