tabelas_cadastro <- c(
    "/txt/InstalacaoOrigem.zip",
    "/txt/InstalacaoDestino.zip",
    "/txt/Mercadoria.zip",
    "/txt/MercadoriaConteinerizada.zip",
    "/txt/MetadadosMovimentacao.zip"
)

links_tb_cadastro <- 
    stringr::str_c(
        "https://web3.antaq.gov.br/ea", 
        tabelas_cadastro
    )

links_tb_cadastro



anos <- seq(2010, 2023, 1)
anos

links_tb_anos <- 
    stringr::str_c(
        "https://web3.antaq.gov.br/ea/txt/",
        anos,
        ".zip" 
    )




baixar_arquivos <- 
    function(url) {
        for (i in 1:length(url)) {
            Sys.sleep(2)
            download.file(
                url = url[i],
                destfile = stringr::str_c("C:/Users/Dell/Documents/dados-antaq/",
                                          basename(url[i])
                )
            )
        }
    }


# baixando tabelas cadastro
baixar_arquivos(links_tb_cadastro)

# baixando tabelas anuais
baixar_arquivos(links_tb_anos)



lista_arquivos <- 
    list.files(
        path = "C:/Users/Dell/Documents/dados-antaq/",
        pattern = ".zip",
        full.names = T
    )


lista_arquivos
#descompactando os arquivos
purrr::map(
    lista_arquivos, 
    unzip, 
    overwrite = F, 
    exdir = "C:/Users/Dell/Documents/dados-antaq/"
)


#excluindo arquivos zip
file.remove(lista_arquivos)



###################### JUNTANDO OS DADOS ########
lista_arquivos <- 
    list.files(
        path = "C:/Users/Dell/Documents/dados-antaq/",
        pattern = ".txt",
        full.names = T
    )

lista_arquivos

##################### DADOS DE ATRACAÇÃO #######
# buscando apenas os arquivos que iniciam os nomes com letras
indice <- 
    stringr::str_detect(
        lista_arquivos, "C:/Users/Dell/Documents/dados-antaq/[:alpha:]"
    )

lista_metadados <- lista_arquivos[indice]

#todos os arquivos que não são metadados
lista_files_ano <- lista_arquivos[!indice]

lista_unicos <- 
    stringr::str_sub(
        lista_files_ano, start = 41, end = -1
    ) |> 
    unique()

# #criando lista para salvar arquivos
# lista <- vector("list", length = length(lista_unicos))
# 
# lista_unicos


salvar_arquivos <- function(posicao) {
    # procurar arquivos os únicos 
    i = stringr::str_detect(
        lista_files_ano,
        stringr::str_c("\\d{4}",lista_unicos[posicao])
    )
    
    
    # filtrar os arquivos
    # ler os arquivos
    df = 
        lista_files_ano[i] |> 
        purrr::map(
            ~ readr::read_delim(
                .x,
                delim = ";",
                col_types = readr::cols(.default = "c"),
                na = c("n/a", ""),
                id = "file"
            ), 
            .progress = T 
        )  |> 
        purrr::list_rbind()
    
    
    df = 
        df |> 
        dplyr::mutate(
            file = stringr::str_extract(
                df$file, "\\d{4}")
        )
    
    df |> 
        readr::write_csv(
            na = "NA",
            file =
                stringr::str_c(
                    "C:/Users/Dell/Documents/dados-antaq/limpos/",
                    stringr::str_sub(lista_unicos[posicao], start = 1, end = -5),
                    ".csv"
                )
        )
    
}

lista_unicos

salvar_arquivos(9)



readr::write_csv(
    x = dados,
    na = "NA",
    file = 
        stringr::str_c(
            "C:/Users/Dell/Documents/dados-antaq/limpos/",
            stringr::str_sub(lista_unicos[2], start = 1, end = -5),
            ".csv"
        )
)


a <- 
    stringr::str_detect(
        lista_files_ano,
        stringr::str_c("\\d{4}",lista_unicos[1])
    )


dados <- 
    lista_files_ano[a] |> 
    purrr::map(
        ~ readr::read_delim(
            .x,
            delim = ";",
            col_types = "c",
            na = c("n/a", ""),
            id = "file"
        ), 
        .progress = T 
    )  |> 
    purrr::list_rbind()

dados <- 
    dados |> 
    dplyr::mutate(file = stringr::str_extract(
        dados$file, "\\d{4}"
    )
    )

#criando diretório
dir.create("C:/Users/Dell/Documents/dados-antaq/limpos/")

readr::write_csv(
    x = dados,
    file = "C:/Users/Dell/Documents/dados-antaq/limpos/atracacao.csv",
    na = "NA"
)


##################### DADOS DE CARGA #######
lista_files <- 
    stringr::str_subset(
        lista_arquivos,pattern = "[0-9]Carga.txt"
    )
lista_files

dados <- 
    lista_files |> 
    purrr::map(
        ~ readr::read_delim(
            .x,
            delim = ";",
            col_types = "c",
            na = c("n/a", ""),
            id = "file"
        ), 
        .progress = T 
    )  |> 
    purrr::list_rbind()

dados <- 
    dados |> 
    dplyr::mutate(file = stringr::str_extract(
        dados$file, "\\d{4}"
    )
    )

#criando diretório
dir.create("C:/Users/Dell/Documents/dados-antaq/limpos/")

readr::write_csv(
    x = dados,
    file = "C:/Users/Dell/Documents/dados-antaq/limpos/atracacao.csv",
    na = "NA"
)