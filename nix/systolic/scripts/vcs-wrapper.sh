#!@shell@

_EXTRA_ARGS="$@"

if ((${VERBOSE:-0})); then
  set -x
fi

_LIB=@lib@
_DATE_BIN=@dateBin@
_VCS_SIM_BIN=@vcsSimBin@
_VCS_SIM_DAIDIR=@vcsSimDaidir@
_VCS_FHS_ENV=@vcsFhsEnv@
_VCS_COV_DIR=@vcsCovDir@

_NOW=$("$_DATE_BIN" "+%Y-%m-%d-%H-%M-%S")
_SYSTOLIC_SIM_RESULT_DIR=${SYSTOLIC_SIM_RESULT_DIR:-"systolic-sim-result"}
_CURRENT="$_SYSTOLIC_SIM_RESULT_DIR"/all/"$_NOW"
mkdir -p "$_CURRENT"
ln -sfn "all/$_NOW" "$_SYSTOLIC_SIM_RESULT_DIR/result"

cp "$_VCS_SIM_BIN" "$_CURRENT/"
cp -r "$_VCS_SIM_DAIDIR" "$_CURRENT/"

if [ -n "$_VCS_COV_DIR" ]; then
  cp -vr "$_LIB/$_VCS_COV_DIR" "$_CURRENT/"
  _CM_ARG="-cm assert -cm_dir $_CURRENT/$_VCS_COV_DIR"
fi

chmod -R +w "$_CURRENT"

_emu_name=$(basename "$_VCS_SIM_BIN")
_daidir=$(basename "$_VCS_SIM_DAIDIR")

export LD_LIBRARY_PATH="$_CURRENT/$_daidir:$LD_LIBRARY_PATH"

"$_VCS_FHS_ENV" -c "$_CURRENT/$_emu_name $_CM_ARG $_EXTRA_ARGS" &> >(tee $_CURRENT/vcs-emu-journal.log)

if [ -n "$_VCS_COV_DIR" ]; then
  "$_VCS_FHS_ENV" -c "urg -dir "$_CURRENT/$_VCS_COV_DIR" -format text"
  cp -vr ./urgReport "$_CURRENT/"
fi

if ((${DATA_ONLY:-0})); then
  rm -f "$_CURRENT/$_emu_name"
fi

set -e _emu_name _daidir

echo "VCS emulator finished, result saved in $_SYSTOLIC_SIM_RESULT_DIR/result"
