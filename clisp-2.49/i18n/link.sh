${MAKE-make} clisp-module \
  CC="${CC}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" \
  CLISP_LINKKIT="$absolute_linkkitdir" CLISP="${CLISP}"
NEW_FILES="gettext.o"
NEW_LIBS="${NEW_FILES} "
NEW_MODULES='i18n'
TO_LOAD='i18n'
TO_PRELOAD="preload.lisp"
