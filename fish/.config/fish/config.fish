function op-getpass
	op get item $argv[1] | jq '.details.fields[] | select(.designation=="password").value'
end

function op-signin
	eval (op signin)
end
