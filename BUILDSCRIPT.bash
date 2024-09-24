#!/bin/bash

CONFIG="${CONFIG:-default}"
while [ $# -gt 0 ] ; do
    if [ "$1" = "--config" ] && [ $# -gt 1 ] ; then
        CONFIG="$2"
        shift
    fi
    shift
done

if ! command -v nproc &> /dev/null ; then
  NUMPROCS="${NUMPROCS:-1}"
else
  NUMPROCS="${NUMPROCS:-$(nproc)}"
fi

if [ "$CONFIG" = "default" ] ; then
  if ! command -v pkg-config --cflags dbus-1 &> /dev/null ; then
    PKG_CONFIG___CFLAGS_DBUS__="-I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include"
  else
    PKG_CONFIG___CFLAGS_DBUS__=$(pkg-config --cflags dbus-1)
  fi
  if ! command -v pkg-config --libs dbus-1 &> /dev/null ; then
    PKG_CONFIG___LIBS_DBUS__="-ldbus-1"
  else
    PKG_CONFIG___LIBS_DBUS__=$(pkg-config --libs dbus-1)
  fi
fi


CXX="${CXX:-g++}"
CXXFLAGS="${CXXFLAGS:--Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -O3 -flto $PKG_CONFIG___CFLAGS_DBUS__}"
CXXARCH="${CXXARCH:--march=native}"
CXXSTD="${CXXSTD:--std=c++2b}"
CXXFLAGSEXTRA="${CXXFLAGSEXTRA:-}"
LDFLAGS="${LDFLAGS:--Wall -Wextra -Wl,--as-needed -Wl,-z,now -O3 -flto=auto -s}"
LDLIBS="${LDLIBS:-$PKG_CONFIG___LIBS_DBUS__ -lcrypto -lsqlite3}"
BIN="${BIN:-signalbackup-tools}"

# CONFIG: brew
if [ "$CONFIG" = "brew" ] ; then
  CXXFLAGS="-Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -O3 -flto"
  LDFLAGS="-Wall -Wextra -O3 -flto=auto"
  LDLIBS="-lcrypto -lsqlite3"
fi

# CONFIG: darwin
if [ "$CONFIG" = "darwin" ] ; then
  CXXFLAGS="-Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -O3 -flto"
  LDFLAGS="-Wall -Wextra -Wl,-framework,CoreFoundation -Wl,-framework,Security -flto -O3"
  LDLIBS="-lcrypto -lsqlite3"
fi

# CONFIG: nixpkgs-darwin
if [ "$CONFIG" = "nixpkgs-darwin" ] ; then
  CXXFLAGS="-Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -O3"
  LDFLAGS="-Wall -Wextra -Wl,-framework,CoreFoundation -Wl,-framework,Security -O3"
  LDLIBS="-lcrypto -lsqlite3"
fi

# CONFIG: windows
if [ "$CONFIG" = "windows" ] ; then
  CXX="x86_64-w64-mingw32-g++"
  CXXFLAGS="-Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -D_WIN32_WINNT=0x600 -I/usr/x86_64-w64-mingw32/include/ -O3 -flto"
  CXXARCH=""
  LDFLAGS="-Wall -Wextra -Wl,--as-needed -L/usr/x86_64-w64-mingw32/lib/ -static -static-libgcc -static-libstdc++ -O3 -flto=auto -s"
  LDLIBS="-ladvapi32 -lcrypt32 -lcrypto -lgdi32 -lsqlite3 -lssp -luser32 -lws2_32"
  BIN="signalbackup-tools_win.exe"
fi

# CONFIG: without_dbus
if [ "$CONFIG" = "without_dbus" ] ; then
  CXXFLAGS="-Wall -Wextra -Woverloaded-virtual -Wshadow -pedantic -DWITHOUT_DBUS -O3 -flto"
  LDLIBS="-lcrypto -lsqlite3"
fi

SRC=("keyvalueframe/statics.cc"
     "signalbackup/tgmapcontacts.cc"
     "signalbackup/tgbuildbody.cc"
     "signalbackup/checkdbintegrity.cc"
     "signalbackup/mergegroups.cc"
     "signalbackup/writeencryptedframe.cc"
     "signalbackup/scanself.cc"
     "signalbackup/applyranges.cc"
     "signalbackup/prepareoutputdirectory.cc"
     "signalbackup/scramble.cc"
     "signalbackup/htmlescapestring.cc"
     "signalbackup/cleandatabasebymessages.cc"
     "signalbackup/setminimumid.cc"
     "signalbackup/htmlprepbody.cc"
     "signalbackup/croptodates.cc"
     "signalbackup/datetomsecssinceepoch.cc"
     "signalbackup/getavatarextension.cc"
     "signalbackup/updategroupmembers.cc"
     "signalbackup/dtimportlongtext.cc"
     "signalbackup/exporttofile.cc"
     "signalbackup/setcolumnnames.cc"
     "signalbackup/handledtgroupchangemessage.cc"
     "signalbackup/tgimportmessages.cc"
     "signalbackup/setlongmessagebody.cc"
     "signalbackup/htmlwritefullcontacts.cc"
     "signalbackup/dtupdateprofile.cc"
     "signalbackup/getrecipientinfofrommap.cc"
     "signalbackup/insertrow.cc"
     "signalbackup/getgroupv1migrationrecipients.cc"
     "signalbackup/htmlwriteblockedlist.cc"
     "signalbackup/listrecipients.cc"
     "signalbackup/importwachat.cc"
     "signalbackup/dumpmedia.cc"
     "signalbackup/makeidsunique.cc"
     "signalbackup/dtimportstickerpacks.cc"
     "signalbackup/getallthreadrecipients.cc"
     "signalbackup/croptothread.cc"
     "signalbackup/initfromdir.cc"
     "signalbackup/fillthreadtablefrommessages.cc"
     "signalbackup/dtsetavatar.cc"
     "signalbackup/dtinsertattachments.cc"
     "signalbackup/unescapexmlstring.cc"
     "signalbackup/getrecipientidfrom.cc"
     "signalbackup/compactids.cc"
     "signalbackup/importfromdesktop.cc"
     "signalbackup/htmlwritecalllog.cc"
     "signalbackup/exporttxt.cc"
     "signalbackup/getdtreactions.cc"
     "signalbackup/signalbackup.cc"
     "signalbackup/decodestatusmessage.cc"
     "signalbackup/htmlwriteavatar.cc"
     "signalbackup/scanmissingattachments.cc"
     "signalbackup/statics_html.cc"
     "signalbackup/exporttodir.cc"
     "signalbackup/getfreedateformessage.cc"
     "signalbackup/getrecipientidfrommapped.cc"
     "signalbackup/setfiletimestamp.cc"
     "signalbackup/exportcsv.cc"
     "signalbackup/utf16tounicodecodepoint.cc"
     "signalbackup/handledtgroupv1migration.cc"
     "signalbackup/migratedatabase.cc"
     "signalbackup/listthreads.cc"
     "signalbackup/htmlgetemojipos.cc"
     "signalbackup/updatethreadsentries.cc"
     "signalbackup/getcustomcolor.cc"
     "signalbackup/updaterecipientid.cc"
     "signalbackup/updatesnippetextrasrecipient.cc"
     "signalbackup/getgroupinfo.cc"
     "signalbackup/deleteattachments.cc"
     "signalbackup/getgroupmembers.cc"
     "signalbackup/customs.cc"
     "signalbackup/warnonce.cc"
     "signalbackup/getminmaxusedid.cc"
     "signalbackup/reordermmssmsids.cc"
     "signalbackup/importcsv.cc"
     "signalbackup/handledtcalltypemessage.cc"
     "signalbackup/htmlwriterevision.cc"
     "signalbackup/statics.cc"
     "signalbackup/getnamefromrecipientid.cc"
     "signalbackup/htmlwritemsgreceiptinfo.cc"
     "signalbackup/updaterows.cc"
     "signalbackup/importthread.cc"
     "signalbackup/htmlwritesettings.cc"
     "signalbackup/decodeprofilechangemessage.cc"
     "signalbackup/remaprecipients.cc"
     "signalbackup/htmlwriteindex.cc"
     "signalbackup/dumpavatars.cc"
     "signalbackup/summarize.cc"
     "signalbackup/removedoubles.cc"
     "signalbackup/getthreadidfromrecipient.cc"
     "signalbackup/cleanattachments.cc"
     "signalbackup/exporthtml.cc"
     "signalbackup/buildsqlstatementframe.cc"
     "signalbackup/htmlescapeurl.cc"
     "signalbackup/gettranslatedname.cc"
     "signalbackup/importtelegramjson.cc"
     "signalbackup/escapexmlstring.cc"
     "signalbackup/tgsetquote.cc"
     "signalbackup/migrate_to_191.cc"
     "signalbackup/htmlpreplinkpreviewdescription.cc"
     "signalbackup/utf8bytestohexstring.cc"
     "signalbackup/handlewamessage.cc"
     "signalbackup/addsmsmessage.cc"
     "signalbackup/tgsetbodyranges.cc"
     "signalbackup/handledtexpirationchangemessage.cc"
     "signalbackup/htmlwritestickerpacks.cc"
     "signalbackup/dtsetsharedcontactsjsonstring.cc"
     "signalbackup/htmlwrite.cc"
     "signalbackup/initfromfile.cc"
     "signalbackup/exportbackup.cc"
     "signalbackup/makefilenameunique.cc"
     "signalbackup/sanitizefilename.cc"
     "signalbackup/importfromplaintextbackup.cc"
     "signalbackup/mergerecipients.cc"
     "signalbackup/htmlwritesearchpage.cc"
     "signalbackup/missingattachmentexpected.cc"
     "signalbackup/dtcreaterecipient.cc"
     "signalbackup/getgroupupdaterecipients.cc"
     "signalbackup/insertreactions.cc"
     "signalbackup/dumpinfoonbadframe.cc"
     "signalbackup/dropbadframes.cc"
     "signalbackup/dtsetcolumnnames.cc"
     "signalbackup/tgsetattachment.cc"
     "signalbackup/exportxml.cc"
     "signalbackup/statics_emoji.cc"
     "signalbackup/updategv1migrationmessage.cc"
     "signalbackup/updatereactionauthors.cc"
     "signalbackup/setrecipientinfo.cc"
     "signalbackup/unicodetoutf8.cc"
     "signalbackup/findrecipient.cc"
     "signalbackup/updateavatars.cc"
     "signalbackup/htmlwriteattachment.cc"
     "signalbackup/dtsetmessagedeliveryreceipts.cc"
     "attachmentframe/statics.cc"
     "logger/isterminal.cc"
     "logger/supportsansi.cc"
     "logger/statics.cc"
     "logger/outputhead.cc"
     "mimetypes/statics.cc"
     "databaseversionframe/statics.cc"
     "xmldocument/xmldocument.cc"
     "endframe/statics.cc"
     "sqlcipherdecryptor/destructor.cc"
     "sqlcipherdecryptor/gethmackey.cc"
     "sqlcipherdecryptor/sqlcipherdecryptor.cc"
     "sqlcipherdecryptor/decryptdata.cc"
     "framewithattachment/setattachmentdata.cc"
     "sharedprefframe/statics.cc"
     "avatarframe/statics.cc"
     "sqlstatementframe/statics.cc"
     "sqlstatementframe/buildstatement.cc"
     "signalplaintextbackupdatabase/signalplaintextbackupdatabase.cc"
     "backupframe/init.cc"
     "desktopattachmentreader/getencryptedattachment.cc"
     "memfiledb/statics.cc"
     "sqlitedb/valueasstring.cc"
     "sqlitedb/prettyprint.cc"
     "sqlitedb/renamecolumn.cc"
     "sqlitedb/availablewidth.cc"
     "sqlitedb/removecolumn.cc"
     "sqlitedb/valueasint.cc"
     "sqlitedb/copydb.cc"
     "sqlitedb/print.cc"
     "sqlitedb/printlinemode.cc"
     "stickerframe/statics.cc"
     "csvreader/readrow.cc"
     "csvreader/read.cc"
     "main.cc"
     "headerframe/statics.cc"
     "desktopdatabase/getkeyfromencrypted.cc"
     "desktopdatabase/decryptkey_mac_linux.cc"
     "desktopdatabase/init.cc"
     "desktopdatabase/getkey.cc"
     "desktopdatabase/getkeyfromencrypted_win.cc"
     "desktopdatabase/readencryptedkey.cc"
     "desktopdatabase/getsecrets_mac.cc"
     "desktopdatabase/getsecrets_linux_secretservice.cc"
     "desktopdatabase/getsecrets_linux_kwallet.cc"
     "desktopdatabase/getkeyfromencrypted_mac_linux.cc"
     "reactionlist/setauthor.cc"
     "jsondatabase/jsondatabase.cc"
     "attachmentmetadata/getattachmentmetadata.cc"
     "fileencryptor/init.cc"
     "fileencryptor/encryptframe.cc"
     "fileencryptor/fileencryptor.cc"
     "fileencryptor/encryptattachment.cc"
     "filedecryptor/getframe.cc"
     "filedecryptor/getframebrute.cc"
     "filedecryptor/filedecryptor.cc"
     "filedecryptor/customs.cc"
     "filedecryptor/initbackupframe.cc"
     "arg/usage.cc"
     "arg/arg.cc"
     "cryptbase/getbackupkey.cc"
     "cryptbase/getcipherandmac.cc")

OBJ=("keyvalueframe/o/statics.o"
     "signalbackup/o/tgmapcontacts.o"
     "signalbackup/o/tgbuildbody.o"
     "signalbackup/o/checkdbintegrity.o"
     "signalbackup/o/mergegroups.o"
     "signalbackup/o/writeencryptedframe.o"
     "signalbackup/o/scanself.o"
     "signalbackup/o/applyranges.o"
     "signalbackup/o/prepareoutputdirectory.o"
     "signalbackup/o/scramble.o"
     "signalbackup/o/htmlescapestring.o"
     "signalbackup/o/cleandatabasebymessages.o"
     "signalbackup/o/setminimumid.o"
     "signalbackup/o/htmlprepbody.o"
     "signalbackup/o/croptodates.o"
     "signalbackup/o/datetomsecssinceepoch.o"
     "signalbackup/o/getavatarextension.o"
     "signalbackup/o/updategroupmembers.o"
     "signalbackup/o/dtimportlongtext.o"
     "signalbackup/o/exporttofile.o"
     "signalbackup/o/setcolumnnames.o"
     "signalbackup/o/handledtgroupchangemessage.o"
     "signalbackup/o/tgimportmessages.o"
     "signalbackup/o/setlongmessagebody.o"
     "signalbackup/o/htmlwritefullcontacts.o"
     "signalbackup/o/dtupdateprofile.o"
     "signalbackup/o/getrecipientinfofrommap.o"
     "signalbackup/o/insertrow.o"
     "signalbackup/o/getgroupv1migrationrecipients.o"
     "signalbackup/o/htmlwriteblockedlist.o"
     "signalbackup/o/listrecipients.o"
     "signalbackup/o/importwachat.o"
     "signalbackup/o/dumpmedia.o"
     "signalbackup/o/makeidsunique.o"
     "signalbackup/o/dtimportstickerpacks.o"
     "signalbackup/o/getallthreadrecipients.o"
     "signalbackup/o/croptothread.o"
     "signalbackup/o/initfromdir.o"
     "signalbackup/o/fillthreadtablefrommessages.o"
     "signalbackup/o/dtsetavatar.o"
     "signalbackup/o/dtinsertattachments.o"
     "signalbackup/o/unescapexmlstring.o"
     "signalbackup/o/getrecipientidfrom.o"
     "signalbackup/o/compactids.o"
     "signalbackup/o/importfromdesktop.o"
     "signalbackup/o/htmlwritecalllog.o"
     "signalbackup/o/exporttxt.o"
     "signalbackup/o/getdtreactions.o"
     "signalbackup/o/signalbackup.o"
     "signalbackup/o/decodestatusmessage.o"
     "signalbackup/o/htmlwriteavatar.o"
     "signalbackup/o/scanmissingattachments.o"
     "signalbackup/o/statics_html.o"
     "signalbackup/o/exporttodir.o"
     "signalbackup/o/getfreedateformessage.o"
     "signalbackup/o/getrecipientidfrommapped.o"
     "signalbackup/o/setfiletimestamp.o"
     "signalbackup/o/exportcsv.o"
     "signalbackup/o/utf16tounicodecodepoint.o"
     "signalbackup/o/handledtgroupv1migration.o"
     "signalbackup/o/migratedatabase.o"
     "signalbackup/o/listthreads.o"
     "signalbackup/o/htmlgetemojipos.o"
     "signalbackup/o/updatethreadsentries.o"
     "signalbackup/o/getcustomcolor.o"
     "signalbackup/o/updaterecipientid.o"
     "signalbackup/o/updatesnippetextrasrecipient.o"
     "signalbackup/o/getgroupinfo.o"
     "signalbackup/o/deleteattachments.o"
     "signalbackup/o/getgroupmembers.o"
     "signalbackup/o/customs.o"
     "signalbackup/o/warnonce.o"
     "signalbackup/o/getminmaxusedid.o"
     "signalbackup/o/reordermmssmsids.o"
     "signalbackup/o/importcsv.o"
     "signalbackup/o/handledtcalltypemessage.o"
     "signalbackup/o/htmlwriterevision.o"
     "signalbackup/o/statics.o"
     "signalbackup/o/getnamefromrecipientid.o"
     "signalbackup/o/htmlwritemsgreceiptinfo.o"
     "signalbackup/o/updaterows.o"
     "signalbackup/o/importthread.o"
     "signalbackup/o/htmlwritesettings.o"
     "signalbackup/o/decodeprofilechangemessage.o"
     "signalbackup/o/remaprecipients.o"
     "signalbackup/o/htmlwriteindex.o"
     "signalbackup/o/dumpavatars.o"
     "signalbackup/o/summarize.o"
     "signalbackup/o/removedoubles.o"
     "signalbackup/o/getthreadidfromrecipient.o"
     "signalbackup/o/cleanattachments.o"
     "signalbackup/o/exporthtml.o"
     "signalbackup/o/buildsqlstatementframe.o"
     "signalbackup/o/htmlescapeurl.o"
     "signalbackup/o/gettranslatedname.o"
     "signalbackup/o/importtelegramjson.o"
     "signalbackup/o/escapexmlstring.o"
     "signalbackup/o/tgsetquote.o"
     "signalbackup/o/migrate_to_191.o"
     "signalbackup/o/htmlpreplinkpreviewdescription.o"
     "signalbackup/o/utf8bytestohexstring.o"
     "signalbackup/o/handlewamessage.o"
     "signalbackup/o/addsmsmessage.o"
     "signalbackup/o/tgsetbodyranges.o"
     "signalbackup/o/handledtexpirationchangemessage.o"
     "signalbackup/o/htmlwritestickerpacks.o"
     "signalbackup/o/dtsetsharedcontactsjsonstring.o"
     "signalbackup/o/htmlwrite.o"
     "signalbackup/o/initfromfile.o"
     "signalbackup/o/exportbackup.o"
     "signalbackup/o/makefilenameunique.o"
     "signalbackup/o/sanitizefilename.o"
     "signalbackup/o/importfromplaintextbackup.o"
     "signalbackup/o/mergerecipients.o"
     "signalbackup/o/htmlwritesearchpage.o"
     "signalbackup/o/missingattachmentexpected.o"
     "signalbackup/o/dtcreaterecipient.o"
     "signalbackup/o/getgroupupdaterecipients.o"
     "signalbackup/o/insertreactions.o"
     "signalbackup/o/dumpinfoonbadframe.o"
     "signalbackup/o/dropbadframes.o"
     "signalbackup/o/dtsetcolumnnames.o"
     "signalbackup/o/tgsetattachment.o"
     "signalbackup/o/exportxml.o"
     "signalbackup/o/statics_emoji.o"
     "signalbackup/o/updategv1migrationmessage.o"
     "signalbackup/o/updatereactionauthors.o"
     "signalbackup/o/setrecipientinfo.o"
     "signalbackup/o/unicodetoutf8.o"
     "signalbackup/o/findrecipient.o"
     "signalbackup/o/updateavatars.o"
     "signalbackup/o/htmlwriteattachment.o"
     "signalbackup/o/dtsetmessagedeliveryreceipts.o"
     "attachmentframe/o/statics.o"
     "logger/o/isterminal.o"
     "logger/o/supportsansi.o"
     "logger/o/statics.o"
     "logger/o/outputhead.o"
     "mimetypes/o/statics.o"
     "databaseversionframe/o/statics.o"
     "xmldocument/o/xmldocument.o"
     "endframe/o/statics.o"
     "sqlcipherdecryptor/o/destructor.o"
     "sqlcipherdecryptor/o/gethmackey.o"
     "sqlcipherdecryptor/o/sqlcipherdecryptor.o"
     "sqlcipherdecryptor/o/decryptdata.o"
     "framewithattachment/o/setattachmentdata.o"
     "sharedprefframe/o/statics.o"
     "avatarframe/o/statics.o"
     "sqlstatementframe/o/statics.o"
     "sqlstatementframe/o/buildstatement.o"
     "signalplaintextbackupdatabase/o/signalplaintextbackupdatabase.o"
     "backupframe/o/init.o"
     "desktopattachmentreader/o/getencryptedattachment.o"
     "memfiledb/o/statics.o"
     "sqlitedb/o/valueasstring.o"
     "sqlitedb/o/prettyprint.o"
     "sqlitedb/o/renamecolumn.o"
     "sqlitedb/o/availablewidth.o"
     "sqlitedb/o/removecolumn.o"
     "sqlitedb/o/valueasint.o"
     "sqlitedb/o/copydb.o"
     "sqlitedb/o/print.o"
     "sqlitedb/o/printlinemode.o"
     "stickerframe/o/statics.o"
     "csvreader/o/readrow.o"
     "csvreader/o/read.o"
     "o/main.o"
     "headerframe/o/statics.o"
     "desktopdatabase/o/getkeyfromencrypted.o"
     "desktopdatabase/o/decryptkey_mac_linux.o"
     "desktopdatabase/o/init.o"
     "desktopdatabase/o/getkey.o"
     "desktopdatabase/o/getkeyfromencrypted_win.o"
     "desktopdatabase/o/readencryptedkey.o"
     "desktopdatabase/o/getsecrets_mac.o"
     "desktopdatabase/o/getsecrets_linux_secretservice.o"
     "desktopdatabase/o/getsecrets_linux_kwallet.o"
     "desktopdatabase/o/getkeyfromencrypted_mac_linux.o"
     "reactionlist/o/setauthor.o"
     "jsondatabase/o/jsondatabase.o"
     "attachmentmetadata/o/getattachmentmetadata.o"
     "fileencryptor/o/init.o"
     "fileencryptor/o/encryptframe.o"
     "fileencryptor/o/fileencryptor.o"
     "fileencryptor/o/encryptattachment.o"
     "filedecryptor/o/getframe.o"
     "filedecryptor/o/getframebrute.o"
     "filedecryptor/o/filedecryptor.o"
     "filedecryptor/o/customs.o"
     "filedecryptor/o/initbackupframe.o"
     "arg/o/usage.o"
     "arg/o/arg.o"
     "cryptbase/o/getbackupkey.o"
     "cryptbase/o/getcipherandmac.o")

num_jobs=${#SRC[@]}

## "wait -n" was introduced in bash 4.3
## "${parameter@P}" was introduced in bash 4.4 (2016)
## both used in parallel for-loop
# check we are using bash, and it is >= 4.4
if [ ! -z ${BASH+x} ] && ( { [ "${BASH_VERSINFO[0]}" -ge 4 ] && [ "${BASH_VERSINFO[1]}" -ge 4 ] ; } || [ "${BASH_VERSINFO[0]}" -gt 4 ]) ; then
  RUNNINGJOBS="\j"  # The prompt escape for number of jobs currently running
                    ### echo "${RUNNINGJOBS}" // parameter expansion
                    ### \j
                    ### echo "${RUNNINGJOBS@P}" // prompt expansion
                    ### 0   // for example)

  for (( i = 0; i < num_jobs; i++ )); do
      while (( ${RUNNINGJOBS@P} >= NUMPROCS )); do
          wait -n
      done
      mkdir -p $(dirname "${OBJ[$i]}")
      if [ ! "${OBJ[$i]}" -nt "${SRC[$i]}" ] ; then
          echo "$CXX -c $CXXFLAGS $CXXFLAGSEXTRA $CXXARCH $CXXSTD ${SRC[$i]} -o ${OBJ[$i]}"
          $CXX -c $CXXFLAGS $CXXFLAGSEXTRA $CXXARCH $CXXSTD "${SRC[$i]}" -o "${OBJ[$i]}" &
      fi
  done
  wait
else
  for (( i = 0; i < num_jobs; i++ )); do
    threads_free=$((num_jobs - i))
    if [[ "$threads_free" -lt "$NUMPROCS" ]] ; then
      threads=$threads_free
    else
      threads=$NUMPROCS
    fi
    for (( t = 0; t < threads; t++ )); do
      (
        curjob=$((i + t))
        mkdir -p $(dirname "${OBJ[$curjob]}")
        if [ ! "${OBJ[$curjob]}" -nt "${SRC[$curjob]}" ] ; then
            echo "$CXX -c $CXXFLAGS $CXXFLAGSEXTRA $CXXARCH $CXXSTD ${SRC[$curjob]} -o ${OBJ[$curjob]}"
            $CXX -c $CXXFLAGS $CXXFLAGSEXTRA $CXXARCH $CXXSTD "${SRC[$curjob]}" -o "${OBJ[$curjob]}"
        fi
      ) &
    done
    wait
    i=$((i + t - 1))
  done
fi

# Linking
echo "$CXX ${OBJ[@]} $LDFLAGS -o $BIN $LDLIBS"
$CXX "${OBJ[@]}" $LDFLAGS -o "$BIN" $LDLIBS


