${MAKE-make} clisp-module \
  CC="${CC}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" \
  CLISP_LINKKIT="$absolute_linkkitdir" CLISP="${CLISP}"
NEW_MODULES='libsvm'
NEW_FILES=''
for f in ${NEW_MODULES}; do NEW_FILES=${NEW_FILES}" ${f}.o"; done
NEW_LIBS="${NEW_FILES} -lm -lsvm"
TO_LOAD='libsvm'
TO_PRELOAD='preload'
