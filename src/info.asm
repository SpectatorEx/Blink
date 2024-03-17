%define NL 0x0D, 0x0A	; Next line.

segment .data
	info_msg	db NL
				db " Welcome to Blink!", 							NL, NL
				db " In this game, colors are randomly generated.",	NL
				db " Use number keys 1-8 to select the color",		NL
				db " that is written in the word until the timer",	NL
				db " runs out. If the color is correct, you earn",	NL 
				db " a point and the timer speed will increase.",	NL
				db " To win, you need to score 1000 points.",		NL, NL
				db " Good luck!",									NL, NL
				db " List of keys:",								NL, NL
				db " [1] - Black.	[5] - Red.",					NL
				db " [2] - Blue.	[6] - Magenta.",				NL
				db " [3] - Green.	[7] - Yellow.",					NL
				db " [4] - Cyan.	[8] - White.",					NL, NL
				db " Source code:",									NL
				db " https://github.com/SpectatorEx/Blink", '$'

	start_msg	db "Press any key to start!", '$'
	restart_msg	db "Restart? (R Key)", '$'