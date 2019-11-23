function op-getpass
  op get item $argv[1] | jq '.details.fields[] | select(.designation=="password").value'
end

function op-getitem
  op get item $argv[1] | jq
end

function op-getsections
  op get item $argv[1] | jq '.details.sections'
end

function op-signin
  eval (op signin)
end

function fish_greeting
  date
end
