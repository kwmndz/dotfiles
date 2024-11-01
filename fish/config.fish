if status is-interactive
	# Commands to run in interactive sessions can go here
	
	# Set my default editor
	set -gx EDITOR nano

	# This prevents me from using python without first being in a venv
	set -g -x PIP_REQUIRE_VIRTUALENV true
	
	# bind alt + a to accept auto complete
	bind \ea accept-autosuggestion	

	# Function prints all abbr and aliases
	function helpme --description "List all abbreviations and aliases"

		echo ""
		set_color --bold yellow
		echo "Abbreviations:"
		set_color normal
		echo "-------------"

		abbr --show | while read -l line
			if string match -q "* -- *" $line
				set -l parts (string split ' -- ' $line)
				set -l abbr_name $parts[1]
				set -l abbr_value $parts[2]

				# Split the second part into two strings based on first space
				set -l abbr_value_parts (string split -m 1 ' ' $abbr_value)

				# Check if the first character of the second part is a single quote
				if not string match -q "'*" $abbr_value_parts[2]
					set abbr_end "'$abbr_value_parts[2]'"
				else
					set abbr_end $abbr_value_parts[2]
				end
				
				

				set_color --bold blue
				echo -n $abbr_value_parts[1]
				set_color normal
				echo -n (string repeat -n (math 8 - (string length $abbr_value_parts[1])) " ") "-->" (string repeat -n (math 3) " ") 
				set_color cyan
				echo $abbr_end
				set_color normal
			end
		end
		
		echo "-------------"		

		# *****fix this part when have time
				
		# echo ""
		# echo "Aliases:"
		# echo "-------"
		
		# functions -n | grep -v ' ' | while read func
		# 	set -l alias_target (functions $func | grep -m1 "^function $func" | awk '{print $4}')
		# 	if test -n "$alias_target"
		# 		echo "$func -> $alias_target"
		# 	end
	
		# end
	end


	# Custom function to create and activate new python venv
	function venv --description "Create and activate a new virtual environment"
		echo "Creating virtual enviroment in "(pwd)"/.venv"
		python3 -m venv .venv --upgrade-deps

		source .venv/bin/activate.fish
		
		# Append .venv to the Git exclude file
		# As long as it isnt already ignored
		if test -e .git
			set line_addition ".venv"
			set file ".git/info/exclude"
			
			if not grep --quiet --fixed-strings --line-regexp "$line_addition" "$file" 2>/dev/null
				echo "$line_addition" >> "$file"
			end
		end
	end

	# Custon function to copy contents of file
	function copy_file_contents --description "Copy the contents of provided input file"
		set -l filename $argv
		if test -f $filename
			cat $filename | clip.exe # Windows copy bin, use fish_clipboard_copy for no windows machine
			echo "Contents of $filename copied to clipboard."
		else
			echo "File $filename not found."
		end
	end
	
	# abbr to go with it
	abbr --add cpf 'copy_file_contents'
	

	# Custom function to download and unzip file from link
	function download_and_unzip --description "Download and unzip file from link"
		set url $argv[1]
		set filename (basename $url)

		echo "Downloading $filename..."
		curl -L -o $filename $url

		if test $status -eq 0
			echo "Download complete. Unzipping $filename..."
			unzip $filename

			if test $status -eq 0
				echo "Unzip complete."
				rm $filename
			else
				echo "Failed to unzip $filename"
			end
		else
			echo "Failed to download $url"
		end
	end

	# abbr to go with func
	abbr --add dzp 'download_and_unzip'

	# abbr to open windows explorer in current dir
	abbr --add exp 'explorer.exe .'	
	
	# abbr to create python venv
	abbr --add penv 'python3 -m venv .venv'

	# abbr to start python venv in current dir
	abbr --add aenv 'source .venv/bin/activate.fish'

	# abbr to autocomplete py or python into python3
	abbr --add py 'python3'
	abbr --add python 'python3'
	
	# abbr to force delete a dir no matter what
	abbr --add rmfd 'rm -r -f '

	# alias to make using github copilot command line easier
	alias copilot='gh copilot'
	alias gcs='gh copilot suggest'
	alias gce='gh copilot explain'
	
	# alias to auto use exa over ls
	alias ls='exa --color=always'
	alias rls='ls'
end

# Function redirects me to ~/ dir if I start wsl from system32
# useful when not starting wsl through a director, as it defaults to system32
function redirect_to_homedir_on_startup #--on-variable PWD
	# Check if this function has already run
	# echo "before"
	if not set -q __check_redirect_run
		set -g __check_redirect_run 1
		
		# echo "made it pre!"
		if string match -q "*System32" $PWD
			cd ~/
			# 	echo "made it last!"
			clear
		else if string match -q "*system32*" $PWD
			cd ~/
			clear
		end
	end
end

# Run the function
redirect_to_homedir_on_startup



