# TODO:
# Command to show multiple pages?
# cmdlet?

# startup, defines display length
$length = 40

# need these due to expanded indexes not allowing operations inside them
$lengthminus1 = $length - 1
$halflength = $length/2
$halflengthminus1 = $length/2-1

# gets usable COM ports
Write-Host "Avalible COM ports:"
[System.IO.Ports.SerialPort]::getportnames()

# runs input in a while loop to ask for COM port, asking for reentry if not valid
while ($COM -isnot [int] -or $open -ne $true) {
	try {
		[int]$COM = Read-Host "COM"
	} catch {
		Write-Host "Not a number"
	}

	$port = New-Object System.IO.Ports.SerialPort COM$COM,9600,None,8,one
	try {
		$port.open()
		$open = $true
	} catch {
		Write-Host "The port is closed, it may be in use or not exist"
	}
}

Write-Host "Port opened"

# in a constant loop so users come back to root unless they exit
while ($true) {
	
	# gets the user command by seperating at the first space if there is one
	$select = Read-Host ":"
	if (-1 -lt $select.IndexOf(" ")) {
		$cmd = -join $select[0..$select.IndexOf(" ")]
		$option = -join $select[$select.IndexOf(" ")..$select.length]
		$cmd = $cmd.trim().ToLower()
		$option = $option.trim()
	} else {
		$cmd = $select
		$option = ""
	}

	# gets flag by looking for a - in the first char of $option
	if ($option[0] -eq "-") {
		$flag = -join $option[0..$option.IndexOf(" ")]
		$option = -join $option[$option.IndexOf(" ")..$option.length]
		$flag = $flag.trim("- ")
		$option = $option.trim()
	} else {
		$flag = ""
	}

	# help
	if ($cmd -eq "help" -or $cmd -eq "h" -or $cmd -eq "?") {
		Write-Host "  help                   Display this message.  Aliases: h, ?
  write [-b] [message]   Displays a message on the screen, leave blank to clear screen.  Aliases: w
      -b                 Disables automatic line breaking
  center [-b] [message]  Displays a centered message on the screen.  Aliases: c
      -b                 Disables automatic line breaking
  scroll [-s] [message]  Scrolls a message over the screen, press any key to interrupt.  Aliases: s
      -s [speed]         Speed of scrolling, in milliseconds
  page [-bsc][message]   Displays a message over several 'pages' for longer strings, press any key to interrupt.  Aliases: p
      -b                 Disables automatic line breaking
      -s [speed]         Speed of pages, in milliseconds
      -c                 Centers the text on each page
  clear                  Clears the terminal.  Aliases: cls
  exit                   Leave the session.  Aliases: quit, q
  
  Examples:
  write foo bar
  w -b foo bar
  scroll -s 400 foo bar
  page -sc 600 foo bar"

	# clear
	} elseif ($cmd -eq "clear" -or $cmd -eq "cls") {
		Clear-Host

	# write
	} elseif ($cmd -eq "write" -or $cmd -eq "w") {
		
		# breaks the line at the end of screen
		# if the character at half the screen isn't a space, non-existent or a -, break it, but don't if it has the -b flag
		if ($option[$length/2] -ne " " -and $option[$length/2] -ne $null -and $option[$length/2-1] -ne "-" -and $flag.Contains("b") -ne $true) {
			for ($i=$length/2; $i -gt 0; $i--) {
				# work backwards to find the closest space
				if ($option[$i] -eq " " -or $option[$i] -eq "-") {
					$break = $i
					# split the string at the space and pad it to the end of the line
					$str1 = -join $option[0..$break]
					$str1 = $str1.trim()
					$str2 = -join $option[$break..$option.length]
					$str2 = $str2.trim()
					for ($i=$break; $i -lt $length/2; $i++) {
						$str1 = $str1 + " "
					}
					# append the strings
					$option = $str1 + $str2
					break
				}
			}
		}
		
		# removes any spaces from the first character of the second line
		if ($option[$length/2] -eq " ") {
			$str1 = -join $option[0..$halflengthminus1]
			$str2 = -join $option[$halflength..$option.length]
			$option = $str1 + $str2.trim()
		}

		# trims the length of the string to screen size
		if ($length -lt $option.length) {
			$option = -join $option[0..$lengthminus1]
		}
		
		# prints string
		$port.write($option)
		# prints blank characters to the end of screen
		for ($i=1; $i -le $length-$option.length; $i++) {
			$port.write(" ")
		}

	# center
	} elseif ($cmd -eq "center" -or $cmd -eq "c") {
		
		# breaks the line at the end of screen
		# if the character at half the screen isn't a space, non-existent or a -, break it, but don't if it has the -b flag
		if ($option[$length/2] -ne " " -and $option[$length/2] -ne $null -and $option[$length/2-1] -ne "-" -and $flag.Contains("b") -ne $true) {
			for ($i=$length/2; $i -gt 0; $i--) {
				# work backwards to find the closest space
				if ($option[$i] -eq " " -or $option[$i] -eq "-") {
					$break = $i
					# split the string at the space
					$str1 = -join $option[0..$break]
					$str1 = $str1.trim()
					$str2 = -join $option[$break..$option.length]
					$str2 = $str2.trim()
					# adds a buffer of spaces to the start of str1
					$buffer = [Math]::Floor([decimal](($length/2-$str1.length)/2))
					for ($i = 0; $i -lt $buffer; $i++) {
						$str1 = " " + $str1
					}
					# pad str1 to the end of the line
					for ($i=$str1.length; $i -lt $length/2; $i++) {
						$str1 = $str1 + " "
					}
					# adds a buffer of spaces to the start of str2
					$buffer = [Math]::Floor([decimal](($length/2-$str2.length)/2))
					for ($i = 1; $i -le $buffer; $i++) {
						$str2 = " " + $str2
					}
					# append the strings
					$option = $str1 + $str2
					break
				}
			}
		# if it has the -b flag, center the second line
		} elseif ($flag.Contains("b") -and $option.length -gt $length/2) {
			$str1 = -join $option[0..$halflengthminus1]
			$str1 = $str1.trim()
			$str2 = -join $option[$halflength..$option.length]
			$str2 = $str2.trim()
			# adds a buffer of spaces to the start of str2
			$buffer = [Math]::Floor([decimal](($length/2-$str2.length)/2))
			for ($i = 0; $i -lt $buffer; $i++) {
				$str2 = " " + $str2
			}
			$option = $str1 + $str2
		} else {
			# adds a buffer of spaces to the start of the string to center it
			$buffer = [Math]::Floor([decimal](($length/2-$option.length)/2))
			for ($i = 1; $i -le $buffer; $i++) {
				$option = " " + $option
			}
		}
		
		# trims the length of the string to screen size
		if ($length -lt $option.length) {
			$option = -join $option[0..$lengthminus1]
		}
		
		# prints string
		$port.write($option)
		# prints blank characters to the end of screen
		for ($i=1; $i -le $length-$option.length; $i++) {
			$port.write(" ")
		}

	# scroll
	} elseif ($cmd -eq "scroll" -or $cmd -eq "s") {
		# sets the flag if there is one
		if ($flag.Contains("s")) {
			$speed = -join $option[0..$option.IndexOf(" ")]
			try {
				$speed = [int]$speed
			} catch {
				Write-Host "invalid parameter, using default speed"
				$speed = 200
			}
			$option = -join $option[$option.IndexOf(" ")..$option.length]
			$option = $option.trim()
		} else {
			$speed = 200
		}
		
		if ($option.length -lt $length/2) {
			# makes option length of the line
			$olength = $option.length
			for ($i=1; $i -le $halflength-$olength; $i++) {
				$option = $option + " "
			}
		} else {
			# adds padding so scrolling isn't end to end
			for ($i=1; $i -le $halflength; $i++) {
				$option = $option + " "
			}
		}
		while ($true) {
			$str = $option
			# trims the length of the string to screen size
			if ($length -lt $str.length) {
				$str = -join $str[0..$halflengthminus1]
			}
			# pads blank characters to the end of screen
			$strlength = $str.length
			for ($i=1; $i -le $length-$strlength; $i++) {
				$str = $str + " "
			}
			# prints string
			$port.write($str)
			# shuffles the order around
			$otemp = $option[0]
			$option = -join $option[1..$option.length]
			$option = -join ($option, $otemp)
			Start-Sleep -m $speed
			# breaks if key pressed and clears screen
			if ([console]::KeyAvailable) {
				for ($i=1; $i -le $length; $i++) {
					$port.write(" ")
				}
				break
			}
		}

	} elseif ($cmd -eq "page" -or $cmd -eq "p") {
		# sets the flag if there is one
		if ($flag.Contains("s")) {
			$speed = -join $option[0..$option.IndexOf(" ")]
			try {
				$speed = [int]$speed
			} catch {
				Write-Host "invalid parameter, using default speed"
				$speed = 3000
			}
			$option = -join $option[$option.IndexOf(" ")..$option.length]
			$option = $option.trim()
		} else {
			$speed = 3000
		}

		# breaks the line
		# if the character at half the screen isn't a space, non-existent or a -, break it, but don't if it has the -b flag
		if ($flag.Contains("b") -ne $true) {
			for ($i=1; $i -le [math]::ceiling($option.length/($length/2)); $i++) {
				if ($option[$i*($length/2)] -ne " " -and $option[$i*($length/2)] -ne $null -and $option[$i*($length/2)-1] -ne "-") {
					for ($j=0; $j -lt $length/2; $j++) {
						# work backwards to find the closest space
						if ($option[$i*($length/2)-$j] -eq " " -or $option[$i*($length/2)-$j] -eq "-") {
							# pad it to the end of the line
							for ($k=$length/2-$j; $k -lt $length/2-1; $k++) {
								$option = $option.Insert($i*($length/2)-$j+1," ")
							}

							break
						}
					}
				}
			}
		}

		# breaks the string into screen-sized chunks
		$outstr = ""
		for ($i=1; $i -le [math]::ceiling($option.length/$length); $i++) {
			$itimeslengthminus1 = $i*$length-1
			$iminus1timeslength = ($i-1)*$length

			# saves $length characters at a time in a buffer for manipulating
			$buffer = -join $option[$iminus1timeslength..$itimeslengthminus1]

			# removes any spaces from the first character of a line
			$buffer = $buffer.TrimStart()
			$str1 = -join $buffer[0..$halflengthminus1]
			$str2 = -join $buffer[$halflength..$buffer.length]
			$str2 = $str2.TrimStart()
			
			# adds the spaces back to the end of the line
			$strlength = $str2.length
			for ($j=1; $j -le $length/2-$strlength; $j++) {
				$str2 = $str2 + " "
			}
			
			$buffer = $str1 + $str2

			# appends the buffer to a string
			$outstr += $buffer
		}

		# breaks the output string into an array $length characters at a time
		$page = @()
		for ($i=1; $i -le [math]::ceiling($outstr.length/$length); $i++) {
			$itimeslengthminus1 = $i*$length-1
			$iminus1timeslength = ($i-1)*$length
			$str = -join $outstr[$iminus1timeslength..$itimeslengthminus1]

			# adds a buffer of spaces to the start of the string to center it
			if ($flag.Contains("c")) {

				# splits the string (again) to maniuplate it
				$str1 = -join $str[0..$halflengthminus1]
				$str1 = $str1.trim()
				$str2 = -join $str[$halflength..$str.length]
				$str2 = $str2.trim()

				# adds spaces to the front of str1
				$buffer = [Math]::Floor([decimal](($length/2-$str1.length)/2))
				for ($j = 1; $j -le $buffer; $j++) {
					$str1 = " " + $str1
				}

				# adds spaces to the front of str2
				$buffer = [Math]::Floor([decimal](($length/2-$str2.length)/2))
				for ($j = 1; $j -le $buffer; $j++) {
					$str2 = " " + $str2
				}

				# adds spaces to the end of str1 so str2 is aligned
				$strlength = $str1.length
				for ($j=1; $j -le $length/2-$strlength; $j++) {
					$str1 = $str1 + " "
				}

				$str = ($str1 + $str2)
			}

			# pads out any remaining lines
			$strlength = $str.length
			for ($j=1; $j -le $length-$strlength; $j++) {
				$str = $str + " "
			}
			$page += $str
		}

		for ($i=1; $i -le $page.length; $i++) {
			echo ($page[$i-1] + ".")
		}

		# prints string
		$i = 0
		while ($true) {
			$port.write($page[$i])
			$i++
			if ($i -ge $page.length) {
				$i = 0
			}
			Start-Sleep -m $speed
			# breaks if key pressed and clears screen
			if ([console]::KeyAvailable) {
				for ($i=1; $i -le $length; $i++) {
					$port.write(" ")
				}
				break
			}
		}

	# exit
	} elseif ($cmd -eq "exit" -or $cmd -eq "quit" -or $cmd -eq "q") {
		break

	# blank
	} elseif ($cmd -eq "") {

	# unknown
	} else {
		Write-Host "unknown command, type 'help' to view help message"
	}
}

# closes the connection and exits
$port.close()
Write-Host "Connection closed"