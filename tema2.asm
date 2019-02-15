extern puts
extern printf

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

; TODO: define functions and helper functions

lungime:
    push ebp
    mov ebp,esp
    
    push edi
	push ecx
   
   xor eax,eax
    mov edi,[ebp+8]

    mov al,0x00
    mov ecx,[inputlen]    
    cld
    repne scasb

    mov eax,edi ;determinare in eax a numarului de caracter
    sub eax,[ebp+8]
	dec eax
    
	pop ecx
    pop edi
    leave
    ret
    
    
xor_strings:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
    
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    mov eax,[ebp+8]
    mov ebx,[ebp+12]

	push eax;aflare lungime siruri in ecx
    push eax
    call lungime
    add esp,4
	mov ecx,eax
	pop eax
    
loop1:
    mov dl,byte [ebx+ecx-1]
    xor dl,byte [eax+ecx-1]
    mov [eax+ecx-1],dl
    loop loop1
    
    pop edx
   pop ecx
    pop ebx
    pop eax
    
    leave
    ret

rolling_xor:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	
	mov eax,[ebp+8]
	push eax;salvare lungime sir in ecx
	push eax
	call lungime
	add esp,4
	mov ecx,eax
	pop eax
	
	push ecx
	xor ecx,ecx
loop2:
	mov bl,byte [eax+ecx]
	sub esp,1
	mov [esp],bl
	xor bl,bh ;initial bh este 0 astfel incat primul element sa ramana la fel
	mov bh,[esp];bh va fi folosit la iteratia urmatoare
	add esp,1
	mov [eax+ecx],bl
	inc ecx
	cmp ecx,[esp]
	jnz loop2

	pop ecx
	pop ebx
	pop eax
	leave
	ret

string_of_chars_to_hex:
	push ebp
	mov ebp,esp

	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov ebx,[ebp+8] ;salvez in ebx sirul
	push ebx
	call lungime
	add esp,4
	mov ecx,eax ;salvez in ecx lungimea sirului
	sub eax,1 ; salvez in eax pozitia la care ajung in ebx

loop3:
	mov dl,byte [ebx+ecx-1]
	push eax
	push edx
	call char_to_hex
	add esp,4
	mov dl,al
	pop eax
	mov [ebx+eax],dl
	dec ecx
	mov dl,byte [ebx+ecx-1]
	push eax
	push edx
	call char_to_hex
	add esp,4
	push edx
	push ebx
	xor edx,edx
	mov ebx,16
	mul ebx
	pop ebx
	pop edx
	mov dl,al
	pop eax
	add [ebx+eax],dl
	dec eax
	loop loop3

	inc eax
	add ebx,eax
	mov eax,ebx

	pop edx
	pop ecx
	pop ebx

	leave
	ret

char_to_hex:
	push ebp
	mov ebp,esp

	push ebx

	xor eax,eax
	xor ebx,ebx

	mov ebx,[ebp+8] 

	cmp ebx,48
	jl niciuna
	cmp ebx,57
	jle cifra
	cmp ebx,65
	jl niciuna
	cmp ebx,70
	jle litera_mare
	cmp ebx,97
	jl niciuna
	cmp ebx,102
	jle litera_mica
	jmp niciuna
cifra:
	sub ebx,48
	jmp niciuna
litera_mica:
	sub ebx,97
	add ebx,10
	jmp niciuna
litera_mare:
	sub ebx,65
	add ebx,10
	jmp niciuna
niciuna:
	mov eax,ebx
	pop ebx

	leave
	ret
	
xor_hex_strings:
	push ebp
	mov ebp,esp

	push ebx
	push ecx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx

	mov eax,[ebp+8]
	mov ebx,[ebp+12]

	push eax ;adresa noului sir1 este in eax
	call string_of_chars_to_hex 
	add esp,4
	
	push eax ;adresa noului sir2 este in ebx
	push ebx
	call string_of_chars_to_hex
	add esp,4
	mov ebx,eax
	pop eax

	push ebx
	push eax
	call xor_strings
	add esp,8
	pop ecx
	pop ebx

	leave
	ret

aflare_valoare:
	push ebp
	mov ebp,esp

	push ebx

	xor eax,eax
	xor ebx,ebx

	push eax
	mov eax,[ebp+8];adresa sirului
	mov bl,byte [eax];caracterul de la adresa data ca parametru
	pop eax
	
	cmp ebx,50
	jl nicio_codif
	cmp ebx,55
	jle codif_numar
	cmp ebx,65
	jl nicio_codif
	cmp ebx,90
	jle codif_caracter
	jmp nicio_codif

codif_caracter:
	sub ebx,65
	jmp nicio_codif
codif_numar:
	sub ebx,50
	add ebx,26
	jmp nicio_codif
nicio_codif:
	mov eax,ebx

	pop ebx
	leave
	ret


decode_char:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx
	push edi

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi

	mov edi,[ebp+16];adresa byte unde se salveaza 
	mov ebx,[ebp+12];index de inceput
	mov edx,[ebp+8];valoarea codificata

	mov byte [edi+1],0 ;initializez byte ul urmator 

	push eax
	mov eax,ebx
	sub eax,3
	cmp eax,0
	jg la_dreapta
	jmp la_stanga

la_dreapta:
	push ecx
	xor ecx,ecx
	mov cl,al
	push edx
	shr dl,cl
	add byte [edi],dl

	sub cl,8
	not cl
	inc cl
	pop edx
	shl dl,cl
	add [edi+1],dl
	pop ecx
	jmp final_decode
	
la_stanga:
	push ecx
	xor ecx,ecx
	not eax
	inc eax
	mov cl,al
	shl dl,cl
	pop ecx
	add byte [edi],dl

final_decode:
	pop eax

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret

aflare_index:
	push ebp
	mov ebp,esp

	xor eax,eax
	xor ebx,ebx
	
	mov ebx,[ebp+8];indexul de inceput a valorii
	add ebx,5
	sub ebx,8
	cmp ebx,0
	jge depaseste
	jmp nu_depaseste

depaseste:
	mov eax,1
	jmp final_aflare_index
nu_depaseste:
	add ebx,8

final_aflare_index:
	leave
	ret

base32decode:
	push ebp
	mov ebp,esp
	
	push ebx
	push ecx
	push edx
	push edi

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx;indexul bitului de inceput a valorii

	mov eax,[ebp+8];sirul vechi
	lea ebx,[ebp+12];folosesc zona alocata pentru a crea noul sir

	mov byte [ebx],cl;il fac 0

	push eax
	push eax
	call lungime
	add esp,4
	mov ecx,eax;salvez in ecx lungimea sirului 
	pop eax

	push ebx

loop4:
	push eax
	push ebx
	push ecx

	push ebx;pun adresa unde se salveaza in decode_char
	push edx;pun indexul bite-ului unde se salveaza in decode_char

	push eax; pun byte ul in aflare_valoare

	push edx; pun indexul de inceput in aflare_index
	call aflare_index
	add esp,4
	
	mov ecx,eax;salvez in ecx informatia daca trec sau nu la byte ul urmator
	mov edx,ebx;salvez in edx indexul de inceput urmator
	call aflare_valoare
	add esp,4

	push eax; pun valoarea in decode_char
	call decode_char
	add esp,12

	cmp ecx,0
	je acelasi_byte
	jmp urm_byte
	
acelasi_byte:
	pop ecx
	pop ebx
	pop eax
	inc eax
	jmp final
urm_byte:
	pop ecx
	pop ebx
	pop eax
	inc eax
	inc ebx

final:
	dec ecx
	cmp ecx,5
	jge loop4

	mov byte [ebx],0
	pop ebx
	
	mov eax,ebx
	pop edx
	pop ecx
	pop ebx
	leave
	ret

find_key:
	push ebp
	mov ebp,esp

	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov eax,[ebp+8];salvez in eax adresa sirului
	push eax
	push eax
	call lungime
	add esp,4
	mov ecx,eax;salvez in ecx lungimea sirului
	pop eax

loop5:
	mov bl,byte[eax]
	xor bl,102 ;xor cu f

	mov dl,byte[eax+1]
	xor dl,111 ;xor cu o
	cmp dl,bl
	jne final_loop5

	mov dl,byte[eax+2]
	xor dl,114; xor cu r
	cmp dl,bl
	jne final_loop5

	mov dl,byte[eax+3]
	xor dl,99; xor cu c
	cmp dl,bl
	jne final_loop5

	mov dl,byte[eax+4]
	xor dl,101; xor cu e
	cmp dl,bl
	jne final_loop5
	jmp loop5_finish


final_loop5:
	inc eax
	dec ecx
	cmp ecx,5
	jge loop5

loop5_finish:
	mov eax,edx
	pop edx
	pop ecx
	pop ebx
	leave
	ret

bruteforce_singlebyte_xor:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov eax,[ebp+8];adresa sirului
	mov ebx,[ebp+12];adresa cheii

	push eax
	push eax
	call find_key
	add esp,4
	mov [ebx],eax
	pop eax

	push eax
	push eax
	call lungime
	add esp,4
	mov ecx,eax;salvare lungime sir in ecx
	pop eax

loop6:
    mov dl,byte [eax+ecx-1]
	xor dl,byte [ebx]
	mov [eax+ecx-1],dl
	loop loop6

	pop edx
	pop ecx
	pop ebx
	pop eax

	leave
	ret

construire_tabel_ordonat:
	push ebp
	mov ebp,esp

	pushad
	mov eax,[ebp+8];adresa tabelului


	mov ecx,0
cauta_spatiu:
	cmp byte[eax+ecx]," "
	je interschimbare_spatiu
final_cauta_spatiu:
	add ecx,2
	cmp ecx,56
	jl cauta_spatiu
interschimbare_spatiu:
	mov dl,byte [eax+ecx]
	mov dh,byte [eax+52]
	mov bl,byte [eax+ecx+1]
	mov bh,byte [eax+53]
	mov byte[eax+ecx],dh
	mov byte[eax+52],dl
	mov byte[eax+ecx+1],bh
	mov byte[eax+53],bl

	mov ecx,0
cauta_punct:
	cmp byte[eax+ecx],"."
	je interschimbare_punct
final_cauta_punct:
	add ecx,2
	cmp ecx,56
	jl cauta_punct
interschimbare_punct:
	mov dl,byte [eax+ecx]
	mov dh,byte [eax+54]
	mov bl,byte [eax+ecx+1]
	mov bh,byte [eax+55]
	mov byte[eax+ecx],dh
	mov byte[eax+54],dl
	mov byte[eax+ecx+1],bh
	mov byte[eax+55],bl


	xor ecx,ecx
for1:
	push ecx
	mov ecx,0
for2:
	mov dl,byte [eax+ecx]
	mov dh,byte [eax+ecx+2]
	cmp dl,dh
	jle end_for2
interschimbare:
	mov bl,byte [eax+ecx+1]
	mov bh,byte [eax+ecx+3]
	mov byte[eax+ecx],dh
	mov byte[eax+ecx+2],dl
	mov byte[eax+ecx+1],bh
	mov byte[eax+ecx+3],bl
end_for2:
	add ecx,2
	cmp ecx,50
	jl for2
end_for1:
	pop ecx
	add ecx,2
	cmp ecx,52
	jl for1

	popad

	leave
	ret


construire_tabel_original:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx

	mov eax,[ebp+8];adresa tabelului
	push eax
	
	mov byte [eax],"e"
	add eax,2
	mov byte [eax],"t"
	add eax,2
	mov byte [eax],"a"
	add eax,2
	mov byte [eax],"o"
	add eax,2
	mov byte [eax],"s"
	add eax,2
	mov byte [eax],"i"
	add eax,2
	mov byte [eax],"n"
	add eax,2
	mov byte [eax],"r"
	add eax,2
	mov byte [eax],"d"
	add eax,2
	mov byte [eax],"h"
	add eax,2
	mov byte [eax],"m"
	add eax,2
	mov byte [eax]," "
	add eax,2
	mov byte [eax],"l"
	add eax,2
	mov byte [eax],"c"
	add eax,2
	mov byte [eax],"w"
	add eax,2
	mov byte [eax],"u"
	add eax,2
	mov byte [eax],"."
	add eax,2
	mov byte [eax],"f"
	add eax,2
	mov byte [eax],"p"
	add eax,2
	mov byte [eax],"y"
	add eax,2
	mov byte [eax],"g"
	add eax,2
	mov byte [eax],"v"
	add eax,2
	mov byte [eax],"k"
	add eax,2
	mov byte [eax],"b"
	add eax,2
	mov byte [eax],"j"
	add eax,2
	mov byte [eax],"x"
	add eax,2
	mov byte [eax],"z"
	add eax,2
	mov byte [eax],"q"
	add eax,2
	mov byte [eax],0

	pop eax
	pop ecx
	pop ebx
	pop eax
	leave
	ret

actualizeaza_vector:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx
	push edi
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi

	mov eax,[ebp+8];caracterul din sir
	mov ebx, [ebp+12]; adresa tabelului
	mov ecx,0
	mov edx,[ebp+16]; adresa vectorului

loop12:
	
	cmp byte[ebx],al
	je loop12_exit
	add ebx,2
	inc ecx
	cmp ecx,28
	jl loop12

loop12_exit:
	inc byte [edx+ecx]

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret
	leave
	ret

construire_tabel_subst:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx
	push edi
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	
	mov eax,[ebp+8];adresa tabelului
	mov ebx,[ebp+12];adresa sirului

	sub esp,100
	lea edx,[esp]

	push ecx
	mov ecx,29
loop_golire:
	mov byte [edx+ecx-1],0
	loop loop_golire
	pop ecx

	push eax
	push ebx
	call lungime
	add esp,4
	mov ecx,eax
	pop eax

loop_vector:
	push eax
	push edx
	push eax
	xor eax,eax
	mov al,byte[ebx+ecx-1]

	push eax
	call actualizeaza_vector
	add esp,12
	pop eax
	loop loop_vector
	mov ecx,0

loop7:
	push eax

	push edx
	call find_freq_char
	add esp,4

	
	mov edi,eax
	pop eax

	push ebx
	mov bl,byte [eax+2*edi]
	mov byte [eax+2*ecx+1],bl
	pop ebx

	inc ecx
	cmp ecx,28
	jl loop7

	add esp,100
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret

find_freq_char:
	push ebp
	mov ebp,esp
	
	push ebx
	push ecx
	push edx
	push edi

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi

	mov eax,[ebp+8];adresa vectorului
	mov ecx,0 ;pentru parcurgerea vectorului
	mov bl,0 ;memoreza maximul
	mov edx,-1 ;memoreaza indicele maximului
loop8:
	cmp byte[eax+ecx],-1
	je final_loop8
	cmp bl,byte [eax+ecx]
	ja final_loop8
	mov bl,byte [eax+ecx]
	mov edx,ecx

final_loop8:
	inc ecx
	cmp ecx,28
	jl loop8

	mov byte[eax+edx],-1

	xor eax,eax
	mov eax,edx
	pop edi
	pop edx
	pop ecx
	pop ebx

	leave
	ret

cauta_in_tabel:
	push ebp
	mov ebp,esp

	push ebx
	push ecx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx

	mov eax,[ebp+8];caracterul din sir
	mov ebx, [ebp+12]; adresa tabelului
	inc ebx;ma intereseaza caracterele codificate
	mov ecx,28

loop11:
	cmp byte[ebx],al
	je loop11_exit
	add ebx,2
	loop loop11

loop11_exit:
	dec ebx;caracterul din alfabetul original
	mov eax,ebx

	pop ecx
	pop ebx

	leave
	ret

break_substitution:
	push ebp
	mov ebp,esp
	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	mov eax,[ebp+12];salvare adresa tabel
	mov ebx,[ebp+8];salvare adresa sir

	push eax
	call construire_tabel_original
	add esp,4

	push ebx
	push eax
	call construire_tabel_subst
	add esp,8

	push eax
	push ebx
	call lungime
	add esp,4
	mov ecx,eax
	pop eax

loop10:
	mov dl,byte[ebx+ecx-1]
	push eax

	push eax
	push edx
	call cauta_in_tabel
	add esp,8
	mov dl,byte[eax]
	mov byte[ebx+ecx-1],dl
	pop eax

	loop loop10

	push eax
	call construire_tabel_ordonat
	add esp,4

	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret

main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	; close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)
	; TASK 1: Simple XOR between two byte streams
        xor eax,eax
        xor ebx,ebx
        xor edi,edi
        mov ebx,ecx
        mov ecx,[inputlen]
        mov edi,ebx
	; TODO: compute addresses on stack for str1 and str2
        push edi 
        call lungime
        add esp,4
        add edi, eax
		inc edi
	; TODO: XOR them byte by byte
	;push addr_str2
	;push addr_str1
	;call xor_strings
	;add esp, 8
        push edi ;adresa cheii
        push ebx ;adresa mesajului
     	call xor_strings
		add esp,8
	; Print the first resulting string
	;push addr_str1
	;call puts
	;add esp, 4
	push ecx
	push eax
        push ebx
        call puts
        add esp,4
	pop eax
	pop ecx
	; TASK 2: Rolling XOR
	; TODO: compute address on stack for str3
	push edi ;trec de str2
	call lungime
	add esp,4
	add edi,eax
	inc edi
	; TODO: implement and apply rolling_xor function
	;push addr_str3
	;call rolling_xor
	;add esp, 4
	push edi
	call rolling_xor
	add esp,4
	; Print the second resulting string
	;push addr_str3
	;call puts
	;add esp, 4
	push ecx
	push eax
	push edi
	call puts
	add esp,4
	pop eax
	pop ecx

	; TASK 3: XORing strings represented as hex strings
	; TODO: compute addresses on stack for strings 4 and 5
	push edi
	call lungime
	add esp,4
	add edi,eax
	inc edi

	mov ebx,edi ;salvez in ebx primul sir
	push edi
	call lungime
	add esp,4
	add edi,eax
	inc edi ;salvez al doilea sir in edi
	; TODO: implement and apply xor_hex_strings
	;push addr_str5
	;push addr_str4
	;call xor_hex_strings
	;add esp, 8
	push eax
	push edi
	push ebx
	call xor_hex_strings
	add esp,8
	mov ebx,eax
	pop eax
	; Print the third string
	;push addr_str4
	;call puts
	;add esp, 4
	push ecx
	push eax
	push ebx
	call puts
	add esp,4
	pop eax
	pop ecx
	; TASK 4: decoding a base32-encoded string
	; TODO: compute address on stack for string 6
	push edi
	call lungime
	add esp,4
	add edi,eax
	inc edi ;salvez sirul in edi
	; TODO: implement and apply base32decode
	;push addr_str6
	;call base32decode
	;add esp, 4
	sub esp,2000;alocare spatiu pe stiva
	push edi
	call base32decode
	add esp,4
	; Print the fourth string
	;push addr_str6
	;call puts
	;add esp, 4
	push ecx
	push eax
	push eax
	call puts
	add esp,4
	pop eax
	pop ecx
	add esp,2000;dezalocare spatiu pe stiva
	; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO: determine address on stack for string 7
	push edi
	call lungime
	add esp,4
	add edi,eax
	inc edi
	; TODO: implement and apply bruteforce_singlebyte_xor
	;push key_addr
	;push addr_str7
	;call bruteforce_singlebyte_xor
	;add esp, 8
	push ecx
	sub esp,4;alocare spatiu pentru cheie
	lea ecx,[esp]
	push ecx
	push edi
	call bruteforce_singlebyte_xor
	add esp,8
	; Print the fifth string and the found key value
	;push addr_str7
	;call puts
	;add esp, 4
	push eax
	push ecx
	push edi
	call puts
	add esp,4
	pop ecx
	pop eax
	;push keyvalue
	;push fmtstr
	;call printf
	;add esp, 8
	push ecx
	push eax
	push dword [ecx]
	push fmtstr
	call printf
	add esp,8
	pop eax
	pop ecx

	add esp,4;dezalocare spatiu pentru cheie
	pop ecx
	; TASK 6: Break substitution cipher
	; TODO: determine address on stack for string 8
	push edi
	call lungime
	add esp,4
	add edi,eax
	inc edi
	; TODO: implement break_substitution
	;push substitution_table_addr
	;push addr_str8
	;call break_substitution
	;add esp, 8
	push ecx
	sub esp,2000;alocare spatiu pentru tabelul de substitutie
	lea ecx,[esp]
	push ecx
	push edi
	call break_substitution
	add esp,8
	; Print final solution (after some trial and error)
	;push addr_str8
	;call puts
	;add esp, 4
	push eax
	push ecx
	push edi
	call puts
	add esp,4
	pop ecx
	pop eax
	; Print substitution table
	;push substitution_table_addr
	;call puts
	;add esp, 4

	push ecx
	push eax
	push ecx
	call puts
	add esp,4
	pop eax
	pop ecx

	add esp,2000;dezalocare spatiu pentru tabelul de substitutie
	pop ecx
	; Phew, finally done
    xor eax, eax
    leave
    ret
