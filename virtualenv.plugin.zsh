_read_venvs()
{
  local workon_home project_fname file
  workon_home=${WORKON_HOME-~/.virtualenvs}
  project_fname=${VIRTUALENVWRAPPER_PROJECT_FILENAME-.project}
  virtualenv_map=()
  for file in $workon_home/*/$project_fname(N); do
    virtualenv_map[${file:h:t}]=$(<$file)
  done
}

_env_is_sane()
{
  [[ $ZSH_SUBSHELL == 0 ]] && \
    type workon &>/dev/null && \
    [[ -z $activating_venv ]] && \
    [[ -z $NO_AUTO_VENV ]]
}

_is_better_match()
{
  [[ $PWD/ =~ $project_path/ ]] && \
    [[ $#project_path > $longest_path ]]
}

_is_new_venv()
{
  [[ -n $new_venv ]] && \
    [[ $new_venv != $current_virtualenv ]]
}

_activate_venv()
{
  current_virtualenv=$new_venv
  activating_venv=1
  print "Activating virtualenv $current_virtualenv..."
  workon $current_virtualenv
  unset activating_venv
}

_left_venv()
{
  [[ -n $current_virtualenv ]] && \
    [[ ! $PWD =~ ${virtualenv_map[$current_virtualenv]} ]]
}

_deactivate_venv()
{
  print "Deactivating virtualenv $current_virtualenv..."
  unset current_virtualenv
  deactivate
}

virtualenv_chpwd()
{
  typeset -A virtualenv_map
  setopt local_options no_auto_pushd
  local project_path longest_path new_venv
  if _env_is_sane; then
    _read_venvs

    for name in ${(k)virtualenv_map}; do
      project_path=$virtualenv_map[$name]

      if _is_better_match; then
        new_venv=$name
        longest_path=$#project_path
      fi
    done

    if _is_new_venv; then
      _activate_venv
    elif _left_venv; then
      _deactivate_venv
    fi
  fi
}

add-zsh-hook chpwd virtualenv_chpwd
