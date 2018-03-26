#!/usr/bin/sh


# Seems to be good funcction coding to echo a single return value and return a 0 or 1, good or bad execution.
# It has to be a single value because the call ret=`call_to` will concate all stdout from the command.
my_func () {
  if something $1; then
    echo "return_value_GOOD"
    return 0
  else
    echo "return_value_BAD"
    return 1
  fi
}

something () {
  return $1
}

if ret=`my_func $1`
then
  echo good - $ret
else
  echo bad - $ret
fi


