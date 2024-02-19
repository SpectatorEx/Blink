segment .data
	info_msg	db "Welcome to Blink!", 							0x0A, 0x0A
				db "Use the number keys 1-8 to select "
				db "the color that the text uses.",					0x0A
				db "If the color is correct, you earn a point.",	0x0A
				db "With each correctly selected color, "
				db "the timer speed will increase.",				0x0A
				db "To win, you need to score 1000 points.",		0x0A, 0x0A
				db "Good luck!",									0x0A, 0x0A
				db "List of keys:",									0x0A, 0x0A
				db "[1] - Black.	[5] - Red.",					0x0A
				db "[2] - Blue.	[6] - Magenta.",					0x0A
				db "[3] - Green.	[7] - Yellow.",					0x0A
				db "[4] - Cyan.	[8] - White.",						0x0A, 0x0A
				db "Created by Spectator.",							0x0A
				db "https://github.com/SpectatorEx", '$'

	start_msg	db "Press any key to start!", '$'
	restart_msg	db "Restart? (R Key)", '$'