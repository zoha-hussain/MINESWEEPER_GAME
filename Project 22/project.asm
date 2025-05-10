INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE=30

.data

;chars used:
;0E2h represents a flag
;0FEh represents a cell that has not been clicked yet
;- represents a cell that has been cleared

boardPrint  BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh
			BYTE 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh, 0FEh	

HiddenBoard BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0
			BYTE 0, 0, 0, 0, 0, 0, 0, 0	
			BYTE 0, 0, 0, 0, 0, 0, 0, 0	

row DWORD 12				;total no. of rows
col DWORD 8					;total no. of cols

i DWORD 0					;used for iterations in 2d array
loopCount DWORD ?			;for storing count of nested loop

nOfMines DWORD ?			;no. of mines adjacent to a particular cell
totalMines DWORD ?			;total mines set in the game

userinput_x DWORD ?			;x-coordinate of cell entered by user
userinput_y DWORD ?			;y-coordinate of cell entered by user
choice BYTE ?				;asking user for their choice when 2 actions are possible
level DWORD ?				;asking user difficulty level
index DWORD ?				;current index based on x and y coordinate entered by user

temp_x dword ?				;generate random x-coordinate to place mine
temp_y dword ?				;generate random y-coordinate to place mine

reEnterIndex DWORD ?		;"boolean" variable which determines whether user wants to re-enter index or not

hyphens DWORD "---"			;for printing

Noofclearedcells DWORD 0	;these are the number of cells that have been cleared
totalcells DWORD 96			;total cells are 12*8

;for filing
filename BYTE "minesweeper.txt",0	;output file
filehandle HANDLE ?					;fileHandle for output file
str1 BYTE "Enter Your Name: ",0		;prompt user for entering name
username BYTE 20 DUP(?)				;username entered by user
lengthGameStatus DWORD ?			
gamestatus BYTE BUFFER_SIZE DUP (?)
win BYTE "won",0
lose BYTE "lost",0
filedata BYTE BUFFER_SIZE  DUP (?)  ;to be written in file

.code

;input  procedures for:
;name of user(filing)
;difficulty level
;x-coordinate
;y-coordinate
;flagging or clearing cell

;-------------------------------------------------------------------------------------------------
takename PROC
	mov edx,offset str1
	call writestring
	mov ecx,BUFFER_SIZE
	mov edx, OFFSET username
	call readstring
ret
takename ENDP
;-------------------------------------------------------------------------------------------------

;procedure for taking difficulty level	
DifficultyLevel PROC

	mwrite "Choose Difficulty Level.."
	call crlf
	mwrite "1 - easy (10 Mines)"
	call crlf 
	mwrite "2 - Intermediate (15 mines)"
	call crlf
	mwrite "3 - Hard (20 Mines)"
	call crlf

	LevelSet:
	call ReadInt 
	mov level, eax
	cmp level, 1
		jz easy
	cmp level, 2
		jz inter
	cmp level, 3
		jz hard

	jmp again

	Easy:
		mov totalMines, 10
	ret 

	Inter:
		mov totalMines, 15
	ret

	Hard:
		mov totalMines, 20
	ret

	again:
		jmp LevelSet 
ret 
DifficultyLevel ENDP

;----------------------------------------------------------------------------------------------------------------------------------

;procedure for input of index(row+col)
inputIndex PROC
	
	inputRow:
	call crlf
	mwrite "Enter x-coordinate(row) of cell:";
	call readInt
	mov userinput_x, eax
	call crlf

	;check if entered row is valid or not
	cmp eax, row			;first, comparing if entered index is greater than total rows
		ja reEnterRow		;if it is above row, ask the user to re-enter row
	cmp eax, 0				;if not above, check if it is greater than zero
		jb reEnterRow		;if less than zero, re-enter. Else, input columns
		jmp inputCol

	reEnterRow:
		mwrite "Invalid x-coordinate! It should be greater than zero and less than total number of rows(12)"
		call crlf
	jmp inputRow

	inputCol:
		mwrite "Enter y-coordinate(row) of cell:";
		call readInt
		mov userinput_y, eax
		call crlf

	; check if entered col is valid or not
	cmp eax, col		;first, comparing if entered index is greater than total cols
		ja reEnterCol   ;if it is above cols, ask the user to re-enter col
	cmp eax, 0			;if not above, check if it is greater than zero
		jb reEnterCol	;if less than zero, re-enter. Else, ask user whether they want to flag or clear
	jmp next

	reEnterCol:
		mwrite "Invalid y-coordinate! It should be greater than zero and less than total number of cols(8)"
		call crlf
	jmp inputCol

	next: 
		call flagOrClear
		cmp reEnterIndex, 1  ;if index must be re-entered(as per user's choice)
	je inputRow

ret
inputIndex ENDP

;----------------------------------------------------------------------------------------------------------------------------------

; procedure for asking if user wants to flag the cell or clear it

flagOrClear PROC

	mov reEnterIndex, 0

	call crlf
	mwrite "Enter 'f' to flag mine, and 'c' to clear it:";

	input:
	mov eax, 0
	call readChar
	call writeChar
	mov choice, al

	cmp choice, 'f'
	je flag
	cmp choice, 'F'
	je flag
	cmp choice, 'c'
	je clear
	cmp choice, 'C'
	je clear

	;if user entered neither, ask user to re-enter values.
	call crlf
	mwrite "Kindly enter either 'f' or 'c'! ";
	call crlf
	jmp input

	Flag:
		call flagCell
		jmp callinputagain
	Clear:
		mov esi, OFFSET boardPrint
		; now we must move to the required row
		mov edx, col
		imul edx, userinput_x
		add esi, edx
		add esi, userinput_y

		; now esi contains index entered by user

		; setting the offset for hidden board
		mov edi, OFFSET hiddenboard
	
		;now we must move to the required row
		add edi, edx
		add edi, userinput_y

		; now edi contains index entered by user
		mov eax, 0
		mov al, [edi]
		cmp al, 9
		jne callFunc
		je calllose

		calllose:
			call crlf
			mwrite "YOU LOST !"
			mov ebx,0
			mov ecx, lengthof lose
			mov eax,0
			L4:
			mov al,lose[ebx]
			mov gamestatus[ebx],al
			add ebx,TYPE gamestatus
			loop L4

			mov eax, lengthof lose
			mov lengthGameStatus, eax
			call createmfile
			exit

		callFunc:
			;pushing offsets
			push esi
			push edi

			call ClearCells	

			mov eax,totalcells
			sub eax,Noofclearedcells
			cmp eax,totalmines
			je callwin
			jne callinputagain

		callwin:
			call crlf
			mwrite "YOU WIN !"
			mov ebx,0
			mov ecx, lengthof win
			mov eax,0
			L3:
			mov al,win[ebx]
			mov gamestatus[ebx],al
			add ebx,TYPE gamestatus
			loop L3

			mov eax, lengthof win
			mov lengthGameStatus, eax
			call createmfile
			exit

		callinputagain:
		pop esi
		pop edi
			call crlf
			mov ebx, offset boardprint
			call print2dArray
			call inputIndex
	
ret 
flagOrClear ENDP


;-------------------------------------------------------------------------------------------------
createmfile PROC
	call mergedata		;merging username + gameStatus to write in file
	
	creatingFile:
		mov edx,offset filename
		call createOutputFile
		mov filehandle,eax
	
	writingToFile:
		mov eax,filehandle   
		mov ecx, ebx
		mov edx, OFFSET filedata 
		call writetofile
		call closeFile
ret
createmfile ENDP

;----------------------------------------------------------------------------------------------------------------------------------
mergedata PROC

	mov ebx,0

	L1:
		mov al,username[ebx] 
		cmp al, 'a'
		jb checkCapitalLetter
		cmp al, 'z'
		jbe copyData

		checkCapitalLetter:
			cmp al, 'A'
			jb copyGameStatus
			cmp al, 'Z'
			ja copyGameStatus

		copyData:
			mov filedata[ebx],al
			add ebx,TYPE filedata
	jmp L1
	
	copyGameStatus:
	mov filedata[ebx],' '
	add ebx,TYPE filedata

	mov ecx,lengthgamestatus
	mov esi,0
	mov eax,0
	L2:
		mov al,gamestatus[esi] 
		mov filedata[ebx],al
		add ebx,TYPE filedata
		add esi,TYPE gamestatus
	loop L2

ret
mergedata ENDP

;----------------------------------------------------------------------------------------------------------------------------------

;procedure for flagging a cell
flagCell PROC
	
	;setting row of cell
	mov ebx, OFFSET boardPrint
	;now we must move to the required row
	mov edx, userinput_x
	imul edx, lengthof boardPrint * type boardPrint
	add ebx, edx

	;setting col of cell
	mov esi, userinput_y
	imul esi, type boardPrint

	mov eax, 0E2h   
	cmp [ebx+esi], eax   ;checking if cell is already flagged or not
	jne setFlag   ;if not already flagged, set it now
	;else, ask user what they want to do
	userInput:
		call actionForFlaggedCell
		cmp choice, 'r'
		je removeFlag
		cmp choice, 'R'
		je removeFlag
		cmp choice, 'e'
		je returnToInputIndex
		cmp choice, 'E'
		je returnToInputIndex
		;if neither r nor e were entered
		mwrite "Enter a valid option(r for removing, e for entering new index):"
		jmp userInput

	setFlag: 
		mov eax, 0E2h
		mov [ebx+esi], al

		call crlf
		mwrite "Flag set!"

		jmp endProc
	removeFlag:
		mov eax, 0FEh
		mov [ebx+esi], al
		
		call crlf
		mwrite "Flag removed!"
		jmp endProc
	returnToInputIndex:
		mov eax, 1
	endProc: mov reEnterIndex, eax
ret 
flagCell ENDP

;----------------------------------------------------------------------------------------------------------------------------------

;procedure which asks what user wants to do if cell is already flagged

actionForFlaggedCell PROC
	call crlf
	mwrite "There is already a flag here! Enter 'r' to remove flag, and 'e' if you want to enter some other index:"
	call readChar
	call writeChar
	mov choice, al
ret	
actionForFlaggedCell ENDP

;-----------------------------------------------------------------------------------------------------------------------------------

;procedure for clearing cells

ClearCells Proc
	
	; setting ebp to access parameters
	
	Enter 0,0

	mov esi, [ebp + 12]			; display board 
	mov edi, [ebp + 8]			; hidden board

	; creating copy of offsets for clearing lower section of board 
	mov ebx, [ebp + 12]			
	mov edx, [ebp + 8]			

	mov ecx, userinput_x			
	inc ecx  ;because of 0 based index

	mov eax, 0  ;initialization to avoid garbage values

	; checking if the row has a number other than zero or nine, if so, function ends - no need to go further 
	mov al, [edi]
	cmp eax, 0
	jnz EndofFunction

	Clear_upper:
		;mov index value to al
		mov al, [edi]
		cmp eax, 0
		jnz Resetting
		;if not equal to zero, then place the number of mines at this index

		;clear cells on both sides
		call clearRight
		call clearLeft

		;to indicate an iteration
		dec ecx
		cmp ecx, 0
		jz resetting 

		; subtracting a row from the original address saved in the stack
		; updating the original address off display board index
		sub esi, col
		mov [ebp + 12], esi

		; updating the original address off hidden board index
		sub edi, col
		mov [ebp + 8], edi

		; next iteration
		jmp Clear_upper
	Resetting:
		cmp ecx, 0
		jz Continue

		; if number of mines were placed, then place in display board
		inc Noofclearedcells
		mov al,[edi]
		mov [esi], al
	
	; continue from below the chosen index
	Continue:
		; adding col to move one row below the row entered by user
		add ebx, col		
		mov esi, ebx
		mov [ebp + 12], esi   ;display board

		add edx, col		
		mov edi, edx
		mov [ebp + 8], edi    ;hidden board

		mov ecx, 12				;no of rows
		sub	ecx, userinput_x    ;to determine no. of rows below current row
		dec ecx
		mov eax, 0  ;initialization to avoid garbage values
	Clear_lower:

		;mov index value to al
		mov al, [edi]
		cmp eax, 0
		jnz EndofFunction

		;clear cells on both sides
		call ClearRight
		call clearleft

		;for iterations
		dec ecx
		cmp ecx, 0
		;if all rows have been checked, end function
		jz returnFromFunc

		;incrementing rows for boardprint
		add esi, col
		mov [ebp + 12], esi

		; incrementing rows for hiddenboard
		add edi, col
		mov [ebp + 8], edi

		jmp clear_lower

		cmp ecx, 0
		jz returnFromFunc

	EndOfFunction:
		;placing number of mines
		inc Noofclearedcells
		mov al,[edi]
		mov [esi], al

	returnFromFunc:
		pop ebp
    ret 8
ClearCells ENDP

;----------------------------------------------------------------------------------------------------------------------------------

ClearRight PROC

	;pushing other 
	push ecx
	push esi
	push edi

	;for accessing parameters
	Enter 0,0

	mov esi, [ebp + 32]			; display board 
	mov edi, [ebp + 28]			; hidden board
	mov ecx, 8
	sub ecx, userinput_y        ; to determine no of cols on the right side
	
	mov eax, 0					;initialization to avoid garbage values
	mov al, [edi]

	cmp al, 0
	jz ClearSingleCell 
	jmp PlaceNoOfMines  ;if not zero

	Section:
		cmp ecx, 0
		jz EndOfFunction    ;if all cols have been checked, end function

		;copy value of index
		mov al, [edi]
		cmp al, 0
		jz ClearSingleCell
		jnz PlaceNoOfMines

	ClearSingleCell:
		mov al, '-'
		mov [esi], al
		dec ecx
		;mov to next col
		inc esi
		inc edi
		inc Noofclearedcells
		jmp Section

	PlaceNoOfMines:
		mov eax, 0   ;initialization to avoid garbage values
		mov al, [edi]
		mov [esi], al
		dec ecx
		inc esi
		inc edi
		inc Noofclearedcells

	EndOfFunction:

		pop ebp 
		pop EDI
		pop ESI
		pop ECX

	ret 
ClearRight endp

;--------------------------------------------------------------------------------------------------------------;

CLearLeft PROC

	push ecx
	push esi
	push edi

	;for accessing parameters
	Enter 0,0

	mov eax, 0  ;initialization to avoid garbage values

	mov esi, [ebp + 32]			; display board
	dec esi						; moving cell to left side
	mov edi, [ebp + 28]			; hidden board
	dec edi						; moving cell to left side

	mov ecx, userinput_y		; number of cols on the left
	mov al, [edi]				;copy data from index
	
	Section:
		cmp ecx, 0
		jz EndOfFunction
		mov al, [edi]
		cmp al, 0
		jz ClearSingleCell
		jnz PlaceNoOfMines

	ClearSingleCell:
		mov al, '-'
		mov [esi], al
		dec ecx
		; move to the left
		dec esi
		dec edi
		inc Noofclearedcells
		jmp Section

	PlaceNoOfMines:
		mov eax,0
		mov al, [edi]
		mov [esi], al	 
		dec ecx
		; move to the left
		dec esi
		dec edi
		inc Noofclearedcells

	EndOfFunction:

		pop ebp 
		pop edi
		pop esi 
		pop ecx 
	ret 
ClearLeft endp

;-------------------------------------------------------------------------------------------------

;procedures for initializing mines

; Place mines using random generator
PlaceMines PROC
	AssigningMines:
		mov ebx, OFFSET HiddenBoard
		call randomize
		;row number
		mov eax, 12
		call RandomRange 
		mov temp_x, eax
		;col number
		mov eax, 8
		call RandomRange 
		mov temp_y, eax

		mov eax, 0
		mov edx, temp_x
			imul edx, lengthof HiddenBoard*type HiddenBoard
		add ebx, edx

		mov esi, temp_y
		imul esi, type HiddenBoard

		mov al, [ebx+esi]
		movzx eax, al

		cmp al, 9
		jz AssigningMines

		mov al, 9
		mov [ebx + esi], al
		;increment the number stored in adjacent cells
		call incrementNumber

ret
PlaceMines ENDP

;-------------------------------------------------------------------------------------------------

;adjusting the numbers on cells that do not have mines
incrementNumber PROC
	
	;we will be incrementing the number stored on each adjacent cell to the mine
	;EXCEPT the cell that already has a mine on it.

	;first, assign to the left side
	left:
		cmp esi, 0      ;checking if column is greater than zero    
		jna right
		;if it is greater than zero, then there are some cells that are left to current cell
		sideLeft:
			mov eax, 0
			mov al, [ebx+(esi-1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je topLeft
			inc al
			mov [ebx+(esi-1)], al
			
		topLeft:
			cmp temp_x, 0   ;checking if row is greater than zero 
			jna bottomLeft
			mov eax, 0
			mov al, [(ebx-lengthof hiddenBoard)+(esi-1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je bottomLeft
			inc al
			mov [(ebx-lengthof hiddenBoard)+(esi-1)], al

		bottomLeft:
			cmp temp_x, 11	;checking if it is greater than/equal to 11(max row index)
			jnb right
			mov eax, 0
			mov al, [(ebx+lengthof hiddenBoard)+(esi-1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je right
			inc al
			mov [(ebx+lengthof hiddenBoard)+(esi-1)], al

	right:
		cmp esi, 7      ;checking if column is greater than/equal to 7(max col index)   
		jnb centre
		;if it is less than 7, then there are some cells that are Right to current cell
		sideRight:
			mov eax, 0
			mov al, [ebx+(esi+1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je topRight
			inc al
			mov [ebx+(esi+1)], al
			
		topRight:
			cmp temp_x, 0   ;checking if row is greater than zero 
			jna bottomRight
			mov eax, 0
			mov al, [(ebx-lengthof hiddenBoard)+(esi+1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je bottomRight
			inc al
			mov [(ebx-lengthof hiddenBoard)+(esi+1)], al

		bottomRight:
			cmp temp_x, 11	;checking if it is greater than/equal to 11(max row index)
			jnb centre
			mov eax, 0
			mov al, [(ebx+lengthof hiddenBoard)+(esi+1)]
			cmp al, 9   ;if there is a mine on it, do not increment
			je centre
			inc al
			mov [(ebx+lengthof hiddenBoard)+(esi+1)], al

	centre:
		topCentre:
			cmp temp_x, 0	  ;checking if row is greater than zero
			jna bottomCentre
			mov eax, 0
			mov al, [ebx+esi-lengthof hiddenBoard]
			cmp al, 9   ;if there is a mine on it, do not increment
			je bottomCentre
			inc al
			mov [ebx+esi-lengthof hiddenBoard], al
		bottomCentre:
			cmp temp_x, 11	;checking if it is greater than/equal to 11(max row index)
			jnb endProc
			mov eax, 0
			mov al, [ebx+esi+lengthof hiddenBoard]
			cmp al, 9   ;if there is a mine on it, do not increment
			je endProc
			inc al
			mov [ebx+esi+lengthof hiddenBoard], al
	endProc:
ret
incrementNumber ENDP

;-------------------------------------------------------------------------------------------------

;loop for assigning all mines
LoopForMines PROC
	call DifficultyLevel 
	mov ecx, totalMines
	Mines:
		call PlaceMines
	loop Mines
	ret
LoopForMines ENDP

;-------------------------------------------------------------------------------------------------

;procedures for printing board:

print2dArray PROC
	push edx
	push ecx
	push esi

	call clrscr

	mov al,' '
	call writeChar
	call writeChar
	call writeChar
	call printColumn
	
	mov ecx, row
	;outer loop
	PrintBoardOuter:
		
		mov loopCount, ecx
		
		; output row index
		mov eax, i
		call writeDec

		; printing space for formatting purposes
		cmp i, 9
		ja printBar
		mov al, ' '
		call writeChar

		printBar:
		mov al, '|'
		call writeChar

		; set counter
		mov ecx, col
		;inner loop
		mov esi, 0
		PrintBoardInner:
			; setting col offset
			mov eax, 0
			mov al, [ebx+esi]
			; output
			cmp al, 0FEh
			je printChar
			cmp al, 10 
 			jnb printChar
			cmp al, 0
			jb printChar
			call writeDec
			jmp printSpace
			printChar: call writeChar
			printSpace:mov al, ' '
			call writeChar
			call writeChar
			inc esi
		Loop PrintBoardInner
		
		inc i	
		add ebx, lengthof boardPrint
		call crlf
		;set counter
		mov ecx, loopCount
	Loop PrintBoardOuter
	mov i, 0
	pop esi
	pop ecx
	pop edx

ret
print2dArray ENDP

;-------------------------------------------------------------------------------------------------

printColumn PROC
	mov ecx, col
	PrintIndices:
		mov eax, col
		sub eax, ecx
		call writeDec
		mov al,' '
		call writeChar
		call writeChar
	Loop PrintIndices

	call crlf
	mov al,' '
	call writeChar
	call writeChar

	mov ecx, col
	mov edx, OFFSET hyphens
	PrintHyphens:
		call writeString
	Loop PrintHyphens
	call crlf
ret 
printColumn ENDP

;-------------------------------------------------------------------------------------------------

main PROC
	call takename
	
	mov ebx, OFFSET HiddenBoard
	call LoopForMines

	mov ebx, OFFSET boardPrint
	call print2dArray

	call inputIndex


exit
main ENDP
end main