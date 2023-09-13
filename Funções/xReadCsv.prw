#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

// **********************************************************
// **** Função que Ler o Arquivo CSV e Retorna os Dados. ****
// **********************************************************
User Function xReadCSV()
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local cLinha     := {}
    Local oArquivo
    Local aLinhas
    Local aCampos    := {}
    Local aDados     := {}
    Local cLib
    Local xRetSys    := GetRemoteType(@cLib)
    Private cDirLog  := GetTempPath() + "log_importacao_protheus\"
    Private cLog     := "" 

	if xRetSys == 1

		cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

		If !Empty(cArqOri)

			//Se a pasta de log não existir, cria ela
			If ! ExistDir(cDirLog)
				MakeDir(cDirLog)
			EndIf
		
			//Definindo o arquivo a ser lido
			oArquivo := FWFileReader():New(cArqOri)
			
			//Se o arquivo pode ser aberto
			If (oArquivo:Open())
		
				//Se não for fim do arquivo
				If ! (oArquivo:EoF())
		
					//Definindo o tamanho da régua
					aLinhas := oArquivo:GetAllLines()
					nTotLinhas := Len(aLinhas)
					ProcRegua(nTotLinhas)
					
					//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
					oArquivo:Close()
					oArquivo := FWFileReader():New(cArqOri)
					oArquivo:Open()
		
					//Enquanto tiver linhas
					While (oArquivo:HasLine())
		
						//Incrementa na tela a mensagem
						nLinhaAtu++
						IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")

						//Pegando a linha atual
						cLinAtu := oArquivo:GetLine()

						//Primeira Linha será o array do cabeçalho, e a segunda será o dados do arquivo.
						if nLinhaAtu == 1
							aCampos := Separa(cLinAtu, ";", .T.)
						else
							AADD(aDados, Separa(cLinAtu, ";", .T.))
						endif
						
					EndDo
		
				Else
					MsgStop("Arquivo não tem conteúdo!", "Atenção")
				EndIf
		
				//Fecha o arquivo
				oArquivo:Close()
			Else
				MsgStop("Arquivo não pode ser aberto!", "Atenção")
			EndIf
		
		EndIf
	
	Else

		// Seleciona o Arquivo
		cFile := cGetFile( "Files CSV|*.csv", "Selecione o Arquivo CSV", 0, , .F., GETF_LOCALHARD, .T., .T.)

		// Trava file para uso.
		nHandle := FT_FUSE(cFile)

		// Se houver erro de abertura abandona processamento
		If nHandle = -1
			MsgStop("Arquivo não pode ser aberto!", "Atenção")
			Return
		Endif

		// Posiciona na primeria linha
		FT_FGoTop()

		// Enquanto não for final do arquivo continua lendo o mesmo.
		While !FT_FEOF()

			nLinhaAtu++
			IncProc("Lendo o Arquivo...")

			// Le conteudo da linha posicionada.
			cLinha := FT_FREADLN()

			if nLinhaAtu == 1
				aCampos := Separa(cLinha, ";", .T.)
			else
				AADD(aDados, Separa(cLinha, ";", .T.))
			endif
			
			// Proxima linha.
			FT_FSKIP()

		EndDo

		// Libera arquivo.
		FT_FUSE()

	EndIf

    RestArea(aArea)

Return {aCampos,aDados}
