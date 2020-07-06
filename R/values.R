site <- "https://transparencia.registrocivil.org.br/registros"

queries <- list(
  all = c("all"),
  births = c("births"),
  marriages = c("marriages"),
  deaths = c("deaths")
)

MONTHS <- c(
  "Todos",
  "Janeiro",
  "Fevereiro",

  # Março
  "Mar\u00e7o",
  "Abril",
  "Maio",
  "Junho",
  "Julho",
  "Agosto",
  "Setembro",
  "Outubro",
  "Novembro",
  "Dezembro"
)

STATES <- c(
  "Todos",
  "Acre",
  "Alagoas",

  # Amapá
  "Amap\\u00e1",
  "Amazonas",
  "Bahia",

  # Ceará
  "Cear\u00e1",

  "Distrito Federal",

  # Espírito Santo
  "Esp\u00edrito Santo",

  # Goiás
  "Goi\u00e1s",

  # Maranhão
  "Maranh\u00e3o",
  "Mato Grosso",
  "Mato Grosso do Sul",
  "Minas Gerais",

  # Pará
  "Par\u00e1",

  # Paraíba
  "Para\u00edba",

  # Paraná
  "Paran\u00e1",
  "Pernambuco",

  # Piauí
  "Piau\u00ed",
  "Rio de Janeiro",
  "Rio Grande do Norte",
  "Rio Grande do Sul",

  # Rondônia
  "Rond\u00f4nia",
  "Roraima",
  "Santa Catarina",

  # São Paulo
  "S\u00e3o Paulo",
  "Sergipe",
  "Tocantins"
)

YEARS <- c(as.character(2015:stringi::stri_sub(Sys.Date(),1L,4L)))
