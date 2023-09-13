#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

// ******************************************************************
// **** Função que retorna o array da Query com o nome do campo. ****
// ******************************************************************
User Function QryGetJs(xQry)
	Local aStru	:= {}
	Local aCab	:= {}
	Local aLin	:= {}
	Local xGir	:= {}
	Local cJson := ""  
	Local i		:= 1
	Local l		:= 1
	Local c		:= 1

	TCQUERY xQry NEW ALIAS "XYZ"
	DbSelectArea("XYZ")

	aStru := XYZ->(dbStruct())
	for i := 1 to len(aStru)
		aadd(aCab,aStru[i,1])
	Next

	XYZ->(DBGOTOP())
	while !XYZ->(eof())

		xGir := {}
		for i := 1 to len(aStru)
			aadd(xGir, &(XYZ->(aStru[i,1])))
		Next
		aadd(aLin,xGir)

	XYZ->(DbSkip())
	endDo
	XYZ->(DbcloseArea())

	cJson += '{"xRet": [' 

	for l := 1 to Len(aLin)
 
		cJson += '{'
	
		for c := 1 to Len(aCab) 
		
			if ValType(aLin[l][c]) == "C"  
				cConteudo := '"'+aLin[l][c]+'" '
			elseif ValType(aLin[l][c]) == "N"
				cConteudo := Alltrim(Str(aLin[l][c]))
			elseif ValType(aLin[l][c]) == "D"
				cConteudo := '"'+dToc(aLin[l][c])+'"'
			elseif ValType(aLin[l][c]) == "L"
				cConteudo := if(aLin[l][c], '"true"' , '"false"') 
			else
				cConteudo := '"'+aLin[l][c]+'"'
			endif
	
			cJson += '"'+aCab[c]+'":' + cConteudo
	
			if c < Len(aCab)
				cJson += ','
			endif
	
		next

		cJson += '}'
		
		if l < Len(aLin)
			cJson += ','
		endif
			
	next

	cJson += ']}'

	oJson := JsonObject():New()
	oJson:fromJson(cJson)

return oJson
