#!/bin/bash

# === CORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'  # Sem cor

# === ÍCONES UNICODE ===
CHECK_MARK='✅'
CROSS_MARK='❌'
WARNING='⚠️'
INFO='ℹ️'
ARROW='➡️'

# === CONFIGURAÇÕES ===
API_ESPERADA="VORTEXUSCLOUD"
WHITELIST_HOSTNAMES=("app.vexufy.com")
WHITELIST_IPS=("199.85.209.85" "199.85.209.109")
VALIDATED=false
# === CONFIGURAÇÕES DE VERSÃO ===
VERSAO_LOCAL="1.0.1"  # Versão atual do script
URL_SCRIPT="https://raw.githubusercontent.com/MauroSupera/gerenciador-updater/refs/heads/main/pt/p6/gerenciador_pt.sh"  # Link para o conteúdo do script no GitHub

# Obtém o nome do script atual (ex.: gerenciador.sh)
SCRIPT_NOME=$(basename "$0")
SCRIPT_PATH="${BASE_DIR}/${SCRIPT_NOME}"  # Caminho completo do script

# ###########################################
# Função para verificar atualizações automáticas
# - Propósito: Verifica se há uma nova versão do script disponível.
# ###########################################
verificar_atualizacoes() {
    echo -e "${CYAN}======================================${NC}"
    echo -e "       VERIFICANDO ATUALIZAÇÕES"
    echo -e "${CYAN}======================================${NC}"

    # Obtém o conteúdo remoto do GitHub
    CONTEUDO_REMOTO=$(curl -s --max-time 5 "$URL_SCRIPT")
    if [ -z "$CONTEUDO_REMOTO" ]; then
        echo -e "${YELLOW}Não foi possível verificar atualizações. Tente novamente mais tarde.${NC}"
        return
    fi

    # Extrai a versão remota do conteúdo
    VERSAO_REMOTA=$(echo "$CONTEUDO_REMOTO" | grep -oP 'VERSAO_LOCAL="\K[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$VERSAO_REMOTA" ]; then
        echo -e "${YELLOW}Não foi possível extrair a versão do arquivo remoto.${NC}"
        return
    fi

    echo -e "${CYAN}Versão Atual: ${GREEN}${VERSAO_LOCAL}${NC}"
    echo -e "${CYAN}Versão Disponível: ${GREEN}${VERSAO_REMOTA}${NC}"

    # Compara as versões
    if [ "$VERSAO_REMOTA" = "$VERSAO_LOCAL" ]; then
        echo -e "${GREEN}Você está usando a versão mais recente do nosso script.${NC}"
    elif [[ "$VERSAO_REMOTA" > "$VERSAO_LOCAL" ]]; then
        echo -e "${YELLOW}Nova atualização disponível! (${VERSAO_REMOTA})${NC}"
        echo -e "${YELLOW}Instalando atualização automaticamente...${NC}"
        aplicar_atualizacao_automatica
    else
        echo -e "${RED}Erro ao atualizar: A versão disponível (${VERSAO_REMOTA}) é menor que a versão atual (${VERSAO_LOCAL}).${NC}"
    fi
}
# ###########################################
# Função para aplicar atualizações automáticas
# - Propósito: Baixa a nova versão do script e substitui o atual.
# ###########################################
aplicar_atualizacao_automatica() {
    echo -e "${CYAN}Baixando a nova versão do script...${NC}"
    curl -s -o "${BASE_DIR}/script_atualizado.sh" "$URL_SCRIPT"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao baixar a nova versão do script.${NC}"
        menu_principal
        return
    fi

    echo -e "${CYAN}Substituindo o script atual...${NC}"
    mv "${BASE_DIR}/script_atualizado.sh" "${BASE_DIR}/$SCRIPT_PATH"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Atualização aplicada com sucesso! Reiniciando o servidor...${NC}"
        sleep 2
        exec "$SCRIPT_PATH"
    else
        echo -e "${RED}Erro ao aplicar a atualização.${NC}"
    fi
}


# ###########################################
# Função para aplicar atualizações manuais
# - Propósito: Baixa a nova versão do script e substitui o atual.
# ###########################################
aplicar_atualizacao_manual() {
    echo -e "${CYAN}Verificando atualizações manuais...${NC}"

    # Obtém o conteúdo remoto do GitHub
    CONTEUDO_REMOTO=$(curl -s --max-time 5 "$URL_SCRIPT")
    if [ -z "$CONTEUDO_REMOTO" ]; then
        echo -e "${YELLOW}Não foi possível verificar atualizações. Tente novamente mais tarde.${NC}"
        return
    fi

    # Extrai a versão remota do conteúdo
    VERSAO_REMOTA=$(echo "$CONTEUDO_REMOTO" | grep -oP 'VERSAO_LOCAL="\K[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$VERSAO_REMOTA" ]; then
        echo -e "${YELLOW}Não foi possível extrair a versão do arquivo remoto.${NC}"
        return
    fi

    echo -e "${CYAN}Versão Atual: ${GREEN}${VERSAO_LOCAL}${NC}"
    echo -e "${CYAN}Versão Disponível: ${GREEN}${VERSAO_REMOTA}${NC}"

    # Compara as versões
    if [ "$VERSAO_REMOTA" = "$VERSAO_LOCAL" ]; then
        echo -e "${GREEN}Você já está usando a versão mais recente do nosso script.${NC}"
        menu_principal
    elif [[ "$VERSAO_REMOTA" > "$VERSAO_LOCAL" ]]; then
        echo -e "${YELLOW}Nova atualização disponível! (${VERSAO_REMOTA})${NC}"
        echo -e "${YELLOW}Aplicando atualização manualmente...${NC}"
        aplicar_atualizacao_automatica
 else
        echo -e "${RED}Erro ao atualizar: A versão disponível (${VERSAO_REMOTA}) é menor que a versão atual (${VERSAO_LOCAL}).${NC}"
        menu_principal
    fi
}


# === CABEÇALHO DINÂMICO ===
cabecalho() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BOLD}${CYAN}          GERENCIADOR DE SISTEMAS           ${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === VALIDAÇÃO DA API ===
validar_api() {
    API_RECEBIDA=$1
    if [ "$API_RECEBIDA" != "$API_ESPERADA" ]; then
        cabecalho
        echo -e "${RED}${CROSS_MARK} ERRO: API NÃO AUTORIZADA.${NC}"
        echo -e "${YELLOW}${WARNING} Por favor, forneça o arquivo de configuração correto.${NC}"
        echo -e "${YELLOW}${INFO} Entre em contato com nosso suporte: ${CYAN}https://vortexuscloud.com.br${NC}"
        exit 1
    fi
}

# === INICIALIZAÇÃO DO GERENCIADOR ===
inicializar_gerenciador() {
    cabecalho
    echo -e "${YELLOW}${INFO} Validando API...${NC}"
    validar_api "$1"
    echo -e "${GREEN}${CHECK_MARK} API validada com sucesso!${NC}"
    sleep 2
}

# === FUNÇÃO PARA OBTER IPS ===
obter_ips() {
    IP_PRIVADO=$(hostname -I | awk '{print $1}')
    IP_PUBLICO=""
    SERVICOS=("ifconfig.me" "api64.ipify.org" "ipecho.net/plain")

    for SERVICO in "${SERVICOS[@]}"; do
        IP_PUBLICO=$(curl -s --max-time 5 "http://${SERVICO}")
        if [[ $IP_PUBLICO =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            break
        fi
    done

    if [ -z "$IP_PUBLICO" ]; then
        IP_PUBLICO="Não foi possível obter o IP público"
    fi

    echo "$IP_PRIVADO" "$IP_PUBLICO"
}

# === VALIDAÇÃO DO AMBIENTE ===
validar_ambiente() {
    # Verifica se o arquivo firewall.json existe e contém "skip"
    if [ -f "firewall.json" ]; then
        STATUS=$(jq -r '.status' firewall.json 2>/dev/null)
        if [ "$STATUS" = "skip" ]; then
            # Se o status for "skip", pula as verificações visuais
            cabecalho
            echo -e "${CYAN}${INFO} Ambiente já validado anteriormente. Pulando verificações visuais...${NC}"
            sleep 2

            # Realiza as verificações em segundo plano
            validar_em_segundo_plano &
            return 0
        fi
    fi

    # Realiza as verificações normais
    cabecalho
    echo -e "${CYAN}${INFO} Validando ambiente...${NC}"
    sleep 2
    read -r IP_PRIVADO IP_PUBLICO <<< "$(obter_ips)"
    for HOSTNAME in "${WHITELIST_HOSTNAMES[@]}"; do
        RESOLVIDOS=$(getent ahosts "$HOSTNAME" | awk '{print $1}' | sort -u)
        WHITELIST_IPS+=($RESOLVIDOS)
    done

    cabecalho
    echo -e "${YELLOW}${INFO} Informações do ambiente:${NC}"
    echo -e "${CYAN}${ARROW} Hostname atual: $(hostname)${NC}"
    echo -e "${CYAN}${ARROW} IP privado: $IP_PRIVADO${NC}"
    echo -e "${CYAN}${ARROW} IP público: $IP_PUBLICO${NC}"
    echo -e "${CYAN}----------------------------------------------${NC}"
    sleep 3

    if [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PRIVADO} " ]] || [[ " ${WHITELIST_IPS[@]} " =~ " ${IP_PUBLICO} " ]]; then
        echo -e "${GREEN}${CHECK_MARK} Ambiente autorizado! Continuando...${NC}"
        VALIDATED=true

        # Cria o arquivo firewall.json com status "skip"
        echo '{"status": "skip"}' > firewall.json
        return 0
    fi

    while true; do
        cabecalho
        echo -e "${RED}${CROSS_MARK} ERRO: AMBIENTE NÃO AUTORIZADO${NC}"
        echo -e "${YELLOW}${WARNING} Este sistema só pode ser executado em servidores autorizados.${NC}"
        echo -e "${CYAN}${ARROW} Hostname atual: $(hostname)${NC}"
        echo -e "${CYAN}${ARROW} IP privado: $IP_PRIVADO${NC}"
        echo -e "${CYAN}${ARROW} IP público: $IP_PUBLICO${NC}"
        echo -e "${CYAN}----------------------------------------------${NC}"
        echo -e "${YELLOW}${INFO} Servidores autorizados: ${WHITELIST_HOSTNAMES[*]}${NC}"
        echo -e "${YELLOW}${INFO} IPs autorizados: ${WHITELIST_IPS[*]}${NC}"
        echo -e "${CYAN}----------------------------------------------${NC}"
        echo -e "${YELLOW}${INFO} Para adquirir uma licença ou contratar nossos serviços:${NC}"
        echo -e "${CYAN}${ARROW} Acesse: https://vortexuscloud.com.br${NC}"
        sleep 10
    done
}
# === VALIDAÇÃO EM SEGUNDO PLANO ===
validar_em_segundo_plano() {
    # Obtém os IPs privado e público
    read -r IP_PRIVADO IP_PUBLICO <<< "$(obter_ips)"

    # Resolve os hostnames da whitelist
    for HOSTNAME in "${WHITELIST_HOSTNAMES[@]}"; do
        RESOLVIDOS=$(getent ahosts "$HOSTNAME" | awk '{print $1}' | sort -u)
        WHITELIST_IPS+=($RESOLVIDOS)
    done

    # Verifica se o IP privado ou público está na whitelist
    if [[ ! " ${WHITELIST_IPS[@]} " =~ " ${IP_PRIVADO} " ]] && [[ ! " ${WHITELIST_IPS[@]} " =~ " ${IP_PUBLICO} " ]]; then
        # Se o ambiente não estiver autorizado, registra um erro no log
        echo "ERRO: Ambiente não autorizado. IP Privado: $IP_PRIVADO, IP Público: $IP_PUBLICO" >> validacao.log
    fi
}
# === INÍCIO DO SCRIPT ===
inicializar_gerenciador "$1"

if [ "$VALIDATED" = false ]; then
    validar_ambiente
fi

cabecalho
echo -e "${GREEN}${CHECK_MARK} Bem-vindo ao sistema autorizado!${NC}"
echo -e "${CYAN}${INFO} Preparando validações subsequentes...${NC}"
sleep 5

cabecalho
echo -e "${GREEN}${CHECK_MARK} Sistema autorizado e operacional!${NC}"
echo -e "${CYAN}==============================================${NC}"
# ###########################################
# Configurações principais
# - Propósito: Define o diretório base e outras configurações essenciais do sistema.
# - Editar:
#   * `BASE_DIR`: Modifique para alterar o diretório base onde os ambientes serão criados.
#   * `NUM_AMBIENTES`: Ajuste o número de ambientes que deseja criar.
#   * `TERMS_FILE`: Altere o caminho do arquivo de termos, se necessário.
# - Não editar: Não altere a lógica de uso das variáveis, apenas seus valores.
# ###########################################
#!/bin/bash

# === CORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'  # Sem cor

# === ÍCONES UNICODE ===
CHECK_MARK='✅'
CROSS_MARK='❌'
WARNING='⚠️'
INFO='ℹ️'
ARROW='➡️'

# === CONFIGURAÇÕES PRINCIPAIS ===
BASE_DIR="/home/container"  # Diretório base onde os ambientes serão criados.
NUM_AMBIENTES=6 # Número de ambientes que serão configurados.
TERMS_FILE="${BASE_DIR}/termos_accepted.txt"  # Caminho do arquivo que indica a aceitação dos termos.

# === CABEÇALHO DINÂMICO ===
cabecalho() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BOLD}${CYAN}          GERENCIADOR DE SISTEMAS           ${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === ANIMAÇÃO DE TEXTO ===
anima_texto() {
    local texto="$1"
    for ((i = 0; i < ${#texto}; i++)); do
        echo -n "${YELLOW}${texto:i:1}${NC}"
        sleep 0.02
    done
    echo
}

# === EXIBIR OUTDOOR 3D ===
exibir_outdoor_3D() {
    cabecalho
    echo -e "${CYAN}${INFO} Inicializando sistema...${NC}"
    sleep 1

    local width=$(tput cols)  # Largura do terminal
    local height=$(tput lines)  # Altura do terminal
    local start_line=$((height / 3))
    local start_col=$(( (width - 60) / 2 ))  # Centraliza o texto

    # Arte 3D do texto principal
    local outdoor_text=(
        " _   _  ___________ _____ _______   ___   _ _____ "
        "| | | ||  _  | ___ \\_   _|  ___\\ \\ / / | | /  ___|"
        "| | | || | | | |_/ / | | | |__  \\ V /| | | \\ --. "
        "| | | || | | |    /  | | |  __| /   \\| | | |--. \\"
        "\\ \\_/ /\\ \\_/ / |\\ \\  | | | |___/ /^\\ \\ |_| /\\__/ /"
        " \\___/  \\___/\\_| \\_| \\_/ \\____/\\/   \\/\\___/\\____/ "
    )

    # Exibe o texto 3D centralizado
    for i in "${!outdoor_text[@]}"; do
        tput cup $((start_line + i)) $start_col
        echo -e "${CYAN}${outdoor_text[i]}${NC}"
    done

    # Exibe informações adicionais
    local footer="Script Construído por Mauro Gashfix"
    tput cup $((start_line + ${#outdoor_text[@]} + 1)) $(( (width - ${#footer}) / 2 ))
    echo -e "${YELLOW}${footer}${NC}"

    local links="vortexuscloud.com.br & vortexuscloud.com"
    tput cup $((start_line + ${#outdoor_text[@]} + 2)) $(( (width - ${#links}) / 2 ))
    echo -e "${GREEN}${links}${NC}"

spinner() {
    local pid=$1  # ID do processo em segundo plano
    local delay=0.1
    local spin='-\|/'  # Caracteres do spinner
    local char_width=1

    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 3); do
            printf "\r[${spin:$i:1}] ${CYAN}Carregando...${NC}"
            sleep $delay
        done
    done

    printf "\r${GREEN}[✔] Concluído!${NC}       \n"
}

# Exemplo de uso
long_running_task() {
    sleep 5  # Simula uma tarefa longa
}

echo -e "${CYAN}Iniciando sistema...${NC}"
long_running_task &
spinner $!
}

# === EXIBIR TERMOS DE SERVIÇO ===
exibir_termos() {
    exibir_outdoor_3D
    sleep 1

    echo -e "${BLUE}${INFO} Este sistema é permitido apenas na plataforma Vortexus Cloud.${NC}"
    echo -e "${CYAN}==============================================${NC}"

    if [ ! -f "$TERMS_FILE" ]; then
        while true; do
            echo -e "${YELLOW}${WARNING} VOCÊ ACEITA OS TERMOS DE SERVIÇO? (SIM/NÃO)${NC}"
            read -p "> " ACEITE
            if [ "$ACEITE" = "sim" ]; then
                echo -e "${GREEN}${CHECK_MARK} Termos aceitos em $(date).${NC}" > "$TERMS_FILE"
                echo -e "${CYAN}==============================================${NC}"
                echo -e "${GREEN}${CHECK_MARK} TERMOS ACEITOS. PROSSEGUINDO...${NC}"
                break
            elif [ "$ACEITE" = "não" ]; then
                echo -e "${RED}${CROSS_MARK} VOCÊ DEVE ACEITAR OS TERMOS PARA CONTINUAR.${NC}"
            else
                echo -e "${RED}${CROSS_MARK} OPÇÃO INVÁLIDA. DIGITE 'SIM' OU 'NÃO'.${NC}"
            fi
        done
    else
        echo -e "${GREEN}${CHECK_MARK} TERMOS JÁ ACEITOS ANTERIORMENTE. PROSSEGUINDO...${NC}"
    fi
}

# === CRIAR PASTAS DOS AMBIENTES ===
criar_pastas() {
    cabecalho
    echo -e "${CYAN}${INFO} Criando pastas dos ambientes...${NC}"
    sleep 1

    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        if [ ! -d "$AMBIENTE_PATH" ]; then
            mkdir -p "$AMBIENTE_PATH"
            echo -e "${GREEN}${CHECK_MARK} Pasta do ambiente ${i} criada.${NC}"
        else
            echo -e "${YELLOW}${INFO} Pasta do ambiente ${i} já existe.${NC}"
        fi
    done
}

# === ATUALIZAR STATUS DO AMBIENTE ===
atualizar_status() {
    AMBIENTE_PATH=$1
    NOVO_STATUS=$2
    echo "$NOVO_STATUS" > "${AMBIENTE_PATH}/status"
    echo -e "${CYAN}${INFO} Status do ambiente atualizado para: ${GREEN}${NOVO_STATUS}${NC}"
}

# === RECUPERAR STATUS DO AMBIENTE ===
recuperar_status() {
    AMBIENTE_PATH=$1
    if [ -f "${AMBIENTE_PATH}/status" ]; then
        cat "${AMBIENTE_PATH}/status"
    else
        echo "OFF"
    fi
}

# === CORES ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # Sem cor

# === ÍCONES UNICODE ===
CHECK_MARK='✅'
CROSS_MARK='❌'
WARNING='⚠️'
INFO='ℹ️'
ARROW='➡️'

# === CABEÇALHO DINÂMICO ===
cabecalho() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BOLD}${CYAN}          GERENCIADOR DE SISTEMAS           ${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === ANIMAÇÃO DE TEXTO ===
anima_texto() {
    local texto="$1"
    # Aplica a cor amarela ao texto inteiro antes da animação
    echo -n "${YELLOW}"
    for ((i = 0; i < ${#texto}; i++)); do
        echo -n "${texto:i:1}"
        sleep 0.02
    done
    # Reseta a cor após o texto
    echo "${NC}"
}

# === VERIFICAR SESSÕES EM BACKGROUND ===
verificar_sessoes() {
    echo -e "${CYAN}======================================${NC}"
    anima_texto "       VERIFICANDO SESSÕES EM BACKGROUND"
    echo -e "${CYAN}======================================${NC}"

    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"

        # Verifica se o arquivo .session existe
        if [ -f "${AMBIENTE_PATH}/.session" ]; then
            STATUS=$(recuperar_status "$AMBIENTE_PATH")

            # Define o indicador visual de status (círculo colorido)
            if [ "$STATUS" = "ON" ]; then
                INDICADOR_STATUS="${GREEN}${CIRCLE_ON}${NC}"
            else
                INDICADOR_STATUS="${YELLOW}${CIRCLE_OFF}${NC}"
            fi

            # Exibe o status do ambiente
            echo -e "${YELLOW}Verificando ambiente ${i}...${NC}"
            echo -e "${CYAN}Status atual: ${INDICADOR_STATUS}${NC}"

            # Verifica se o status é ON
            if [ "$STATUS" = "ON" ]; then
                COMANDO=$(cat "${AMBIENTE_PATH}/.session")
                if [ -n "$COMANDO" ]; then
                    echo -e "${YELLOW}Executando sessão em background para o ambiente ${i}...${NC}"

                    # Mata qualquer processo residual
                    pkill -f "$COMANDO" 2>/dev/null

                    # Inicia o bot em segundo plano
                    cd "$AMBIENTE_PATH" || continue
                    nohup sh -c "$COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}[SUCESSO] Sessão em background ativada para o ambiente ${i}.${NC}"
                    else
                        echo -e "${RED}[ERRO] Não foi possível ativar a sessão no ambiente ${i}.${NC}"
                    fi
                else
                    echo -e "${YELLOW}[AVISO] Comando vazio encontrado no arquivo .session do ambiente ${i}.${NC}"
                fi
            else
                echo -e "${RED}[IGNORADO] O ambiente ${i} está com status OFF.${NC}"
            fi
        else
            echo -e "${RED}[IGNORADO] Nenhum arquivo .session encontrado no ambiente ${i}.${NC}"
        fi

        echo -e "${CYAN}--------------------------------------${NC}"
    done

    echo -e "${CYAN}======================================${NC}"
    anima_texto "       VERIFICAÇÃO CONCLUÍDA"
    echo -e "${CYAN}======================================${NC}"
}
# === ÍCONES UNICODE ===
CIRCLE_ON='◉'  # Círculo verde para ON
CIRCLE_OFF='○' # Círculo vazio para OFF

# === CABEÇALHO DINÂMICO ===
cabecalho() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${BOLD}${CYAN}          GERENCIADOR DE SISTEMAS           ${NC}"
    echo -e "${CYAN}==============================================${NC}"
}

# === MENU PRINCIPAL ===
menu_principal() {
    cabecalho

    # Executa a verificação de sessões ao carregar o menu
    verificar_sessoes

    # Verifica automaticamente por atualizações
    verificar_atualizacoes

    echo -e "${CYAN}==============================================${NC}"
    echo -e "       GERENCIAMENTO DE SISTEMAS"
    echo -e "${CYAN}==============================================${NC}"

    # Exibe os ambientes configurados dinamicamente
    for i in $(seq 1 $NUM_AMBIENTES); do
        AMBIENTE_PATH="${BASE_DIR}/ambiente${i}"
        STATUS=$(recuperar_status "$AMBIENTE_PATH")
        # Define o indicador visual de status (círculo colorido)
        if [ "$STATUS" = "ON" ]; then
            ICON="${GREEN}${CIRCLE_ON}${NC}"  # Círculo verde para ON
        else
            ICON="${YELLOW}${CIRCLE_OFF}${NC}"  # Círculo vazio para OFF
        fi
        echo -e "${YELLOW}AMBIENTE ${i} | STATUS: ${ICON}${NC}"
    done

    echo -e "${CYAN}==============================================${NC}"
    echo -e "${YELLOW}ESCOLHA UMA OPÇÃO:${NC}"
    echo -e "${GREEN}1-${NUM_AMBIENTES}${NC} - ESCOLHA ENTRE 1-${NUM_AMBIENTES} PARA GERENCIAR UM AMBIENTE"
    echo -e "${YELLOW}AM${NC} - ATUALIZAÇÃO MANUAL"
    echo -e "${RED}0${NC} - REINICIAR CONTAINER"
    echo -e "${CYAN}==============================================${NC}"

    read -p "> " OPCAO_PRINCIPAL

    # Valida a escolha do usuário
    if [[ "$OPCAO_PRINCIPAL" =~ ^[0-9]+$ ]] && [ "$OPCAO_PRINCIPAL" -ge 1 ] && [ "$OPCAO_PRINCIPAL" -le "$NUM_AMBIENTES" ]; then
        # Gerenciar um ambiente específico
        gerenciar_ambiente "$OPCAO_PRINCIPAL"
    elif [[ "$OPCAO_PRINCIPAL" == "AM" || "$OPCAO_PRINCIPAL" == "am" ]]; then
        # Atualização manual
        aplicar_atualizacao_manual
    elif [[ "$OPCAO_PRINCIPAL" == "0" ]]; then
        # Reiniciar o container
        echo -e "${GREEN}CONTAINER REINICIADO COM SUCESSO!${NC}"
        exit 0
    else
        echo -e "${RED}${CROSS_MARK} ESCOLHA INVÁLIDA. TENTE NOVAMENTE.${NC}"
        sleep 2
        menu_principal
    fi
}

# === ESCOLHER BOT PRONTO ===
escolher_bot_pronto() {
    AMBIENTE_PATH=$1
    cabecalho
    anima_texto "ESCOLHER BOT PRONTO"
    echo -e "${CYAN}==============================================${NC}"
    echo -e "${GREEN}1${NC} - BOTS EM PORTUGUÊS"
    echo -e "${GREEN}2${NC} - BOTS EM ESPANHOL"
    echo -e "${RED}0${NC} - VOLTAR"
    echo -e "${CYAN}==============================================${NC}"

    read -p "> " OPCAO_BOT

    case $OPCAO_BOT in
        1)
            listar_bots "$AMBIENTE_PATH" "portugues"
            ;;
        2)
            listar_bots "$AMBIENTE_PATH" "espanhol"
            ;;
        0)
            menu_principal
            ;;
        *)
            echo -e "${RED}${CROSS_MARK} OPÇÃO INVÁLIDA.${NC}"
            sleep 2
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
    esac
}

# === LISTAR BOTS DISPONÍVEIS ===
listar_bots() {
    AMBIENTE_PATH=$1
    LINGUA=$2

    cabecalho
    anima_texto "BOTS DISPONÍVEIS - ${LINGUA^^}"
    echo -e "${CYAN}==============================================${NC}"

    if [ "$LINGUA" = "portugues" ]; then
        BOTS=(
            "BLACK BOT - https://github.com/MauroSupera/blackbot.git"
            "YOSHINO BOT - https://github.com/MauroSupera/yoshinobot.git"
            "MIKASA ASCENDANCY V3 - https://github.com/maurogashfix/MikasaAscendancyv3.git"
            "INATSUKI BOT - https://github.com/MauroSupera/inatsukibot.git"
            "ESDEATH BOT - https://github.com/Salientekill/ESDEATHBOT.git"
            "CHRIS BOT - https://github.com/MauroSupera/chrisbot.git"
            "TAIGA BOT - https://github.com/MauroSupera/TAIGA-BOT3.git"
            "AGATHA BOT - https://github.com/MauroSupera/agathabotnew.git"
        )
    elif [ "$LINGUA" = "espanhol" ]; then
        BOTS=(
            "GATA BOT - https://github.com/GataNina-Li/GataBot-MD.git"
            "GATA BOT LITE - https://github.com/GataNina-Li/GataBotLite-MD.git"
            "KATASHI BOT - https://github.com/KatashiFukushima/KatashiBot-MD.git"
            "CURIOSITY BOT - https://github.com/AzamiJs/CuriosityBot-MD.git"
            "NOVA BOT - https://github.com/elrebelde21/NovaBot-MD.git"
            "MEGUMIN BOT - https://github.com/David-Chian/Megumin-Bot-MD"
            "YAEMORI BOT - https://github.com/OfcKing/SenkoBot-MD"
            "THEMYSTIC BOT - https://github.com/BrunoSobrino/TheMystic-Bot-MD.git"
        )
    fi

    for i in "${!BOTS[@]}"; do
        echo -e "${GREEN}$((i+1))${NC} - ${BOTS[$i]%% -*}"
    done

    echo -e "${RED}0${NC} - VOLTAR"
    echo -e "${CYAN}==============================================${NC}"

    read -p "> " BOT_ESCOLHIDO

    if [ "$BOT_ESCOLHIDO" -ge 1 ] && [ "$BOT_ESCOLHIDO" -le "${#BOTS[@]}" ]; then
        REPOSITORIO="${BOTS[$((BOT_ESCOLHIDO-1))]#*- }"
        verificar_instalacao_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    elif [ "$BOT_ESCOLHIDO" = "0" ]; then
        escolher_bot_pronto "$AMBIENTE_PATH"
    else
        echo -e "${RED}${CROSS_MARK} OPÇÃO INVÁLIDA.${NC}"
        sleep 2
        listar_bots "$AMBIENTE_PATH" "$LINGUA"
    fi
}

# ###########################################
# Função para verificar a instalação de um bot
# - Propósito: Checa se já existe um bot instalado no ambiente. Se sim, oferece a opção de substituí-lo.
# ###########################################
verificar_instalacao_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Já existe um bot instalado neste ambiente.${NC}"
        echo -e "${YELLOW}Deseja remover o bot existente para instalar o novo? (sim/não)${NC}"
        read -p "> " RESPOSTA
        if [ "$RESPOSTA" = "sim" ]; then
            # Ativa a flag antes de chamar remover_bot
            CHAMADA_VERIFICAR_INSTALACAO=true
            remover_bot "$AMBIENTE_PATH"
            # Desativa a flag após a remoção
            CHAMADA_VERIFICAR_INSTALACAO=false
            # Instala o novo bot
            instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
        else
            echo -e "${RED}Retornando ao menu principal...${NC}"
            menu_principal
        fi
    else
        # Se não há bot instalado, instala diretamente
        instalar_novo_bot "$AMBIENTE_PATH" "$REPOSITORIO"
    fi
}
# ###########################################
# Função para instalar um novo bot
# - Propósito: Clona o repositório do bot e verifica os módulos necessários para instalação.
# - Editar: Não é necessário editar a lógica. Apenas ajuste as mensagens, se necessário.
# ###########################################
instalar_novo_bot() {
    AMBIENTE_PATH=$1
    REPOSITORIO=$2
    NOME_BOT=$(basename "$REPOSITORIO" .git)

    echo -e "${CYAN}Iniciando a instalação do bot: ${GREEN}$NOME_BOT${NC}..."
    git clone "$REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Bot $NOME_BOT instalado com sucesso no ambiente $AMBIENTE_PATH!${NC}"
        verificar_node_modules "$AMBIENTE_PATH"
    else
        echo -e "${RED}Erro ao clonar o repositório do bot $NOME_BOT. Verifique a URL e tente novamente.${NC}"
        gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
    fi
}

# ###########################################
# Função para verificar e instalar módulos Node.js
# - Propósito: Certifica-se de que todos os módulos necessários estejam instalados.
# - Editar: Apenas ajuste as mensagens, se necessário.
# ###########################################
verificar_node_modules() {
    AMBIENTE_PATH=$1

    if [ ! -d "${AMBIENTE_PATH}/node_modules" ]; then
        echo -e "${YELLOW}Módulos não instalados neste bot.${NC}"
        echo -e "${YELLOW}Escolha uma opção para instalação:${NC}"
        echo -e "${GREEN}1 - npm install${NC}"
        echo -e "${GREEN}2 - yarn install${NC}"
        echo -e "${RED}0 - Voltar${NC}"
        read -p "> " OPCAO_MODULOS

        case $OPCAO_MODULOS in
            1)
                echo -e "${CYAN}Instalando módulos com npm...${NC}"
                cd "$AMBIENTE_PATH" && npm install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Módulos instalados com sucesso!${NC}"
                else
                    echo -e "${RED}Erro ao instalar módulos com npm.${NC}"
                fi
                ;;
            2)
                echo -e "${CYAN}Instalando módulos com yarn...${NC}"
                cd "$AMBIENTE_PATH" && yarn install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Módulos instalados com sucesso!${NC}"
                else
                    echo -e "${RED}Erro ao instalar módulos com yarn.${NC}"
                fi
                ;;
            0)
                gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
                ;;
            *)
                echo -e "${RED}Opção inválida.${NC}"
                verificar_node_modules "$AMBIENTE_PATH"
                ;;
        esac
    else
        echo -e "${GREEN}Todos os módulos necessários já estão instalados.${NC}"
    fi

    # Redireciona para o menu do ambiente após a instalação
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}

# ###########################################
# Função para remover bot atual
# - Propósito: Remove todos os arquivos do ambiente para liberar espaço para outro bot.
# - Editar: Apenas ajuste as mensagens, se necessário.
# ###########################################
remover_bot() {
    AMBIENTE_PATH=$1

    if [ -f "${AMBIENTE_PATH}/package.json" ]; then
        echo -e "${YELLOW}Bot detectado neste ambiente.${NC}"
        echo -e "${RED}Deseja realmente remover o bot atual? (sim/não)${NC}"
        read -p "> " CONFIRMAR
        if [ "$CONFIRMAR" = "sim" ]; then
            # Remove todos os arquivos do ambiente
            find "$AMBIENTE_PATH" -mindepth 1 -exec rm -rf {} + 2>/dev/null
            
            # Verifica se o diretório está vazio após a remoção
            if [ -z "$(ls -A "$AMBIENTE_PATH")" ]; then
                echo -e "${GREEN}Bot removido com sucesso.${NC}"
                gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
                
                # Verifica se foi chamada por verificar_instalacao_bot
                if [ "$CHAMADA_VERIFICAR_INSTALACAO" = false ]; then
                    # Retorna ao menu do ambiente
                    AMBIENTE_NUM=$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')
                    gerenciar_ambiente "$AMBIENTE_NUM"
                fi
            else
                echo -e "${RED}Erro ao remover o bot.${NC}"
            fi
        else
            echo -e "${RED}Remoção cancelada.${NC}"
        fi
    else
        echo -e "${RED}Nenhum bot encontrado neste ambiente.${NC}"
    fi

    # Se não for chamada por verificar_instalacao_bot, retorna ao menu principal
    if [ "$CHAMADA_VERIFICAR_INSTALACAO" = false ]; then
        AMBIENTE_NUM=$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')
        gerenciar_ambiente "$AMBIENTE_NUM"
    fi
}
# ###########################################
# Função para clonar repositório
# - Propósito: Permite clonar repositórios públicos e privados no ambiente.
# ###########################################
clonar_repositorio() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "CLONAR REPOSITÓRIO"
    echo -e "${CYAN}======================================${NC}"

    echo -e "${YELLOW}1 - Clonar repositório público${NC}"
    echo -e "${YELLOW}2 - Clonar repositório privado${NC}"
    echo -e "${RED}0 - Voltar ao menu do ambiente${NC}"
    read -p "> " OPCAO_CLONAR

    case $OPCAO_CLONAR in
        1)
            echo -e "${CYAN}Forneça a URL do repositório público:${NC}"
            read -p "> " URL_REPOSITORIO
            if [[ $URL_REPOSITORIO != https://github.com/* ]]; then
                echo -e "${RED}URL inválida! Certifique-se de fornecer uma URL válida do GitHub.${NC}"
                clonar_repositorio "$AMBIENTE_PATH"
                return
            fi
            echo -e "${CYAN}Clonando repositório público...${NC}"
            git clone "$URL_REPOSITORIO" "$AMBIENTE_PATH" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Repositório clonado com sucesso!${NC}"
            else
                echo -e "${RED}❌ Erro ao clonar o repositório. Verifique a URL e tente novamente.${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}Forneça a URL do repositório privado:${NC}"
            read -p "> " URL_REPOSITORIO
            echo -e "${CYAN}Usuário do GitHub:${NC}"
            read -p "> " USERNAME
            echo -e "${CYAN}Forneça o token de acesso (mantenha-o seguro):${NC}"
            read -s -p "> " TOKEN
            echo
            GIT_URL="https://${USERNAME}:${TOKEN}@$(echo $URL_REPOSITORIO | cut -d/ -f3-)"
            echo -e "${CYAN}Clonando repositório privado...${NC}"
            git clone "$GIT_URL" "$AMBIENTE_PATH" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Repositório privado clonado com sucesso!${NC}"
            else
                echo -e "${RED}❌ Erro ao clonar o repositório privado. Verifique suas credenciais e tente novamente.${NC}"
            fi
            ;;
        0)
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            ;;
        *)
            echo -e "${RED}❌ Opção inválida. Tente novamente.${NC}"
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
    esac

    # Redireciona ao menu do ambiente após a operação
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}

# ###########################################
# Função para o menu pós-clone
# - Propósito: Permite que o usuário escolha o que fazer após clonar um repositório.
# ###########################################
pos_clone_menu() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "O QUE VOCÊ DESEJA FAZER AGORA?"
    echo -e "${CYAN}======================================${NC}"

    echo -e "${YELLOW}1 - Executar o bot${NC}"
    echo -e "${YELLOW}2 - Instalar módulos${NC}"
    echo -e "${RED}0 - Voltar ao menu do ambiente${NC}"
    read -p "> " OPCAO_POS_CLONE

    case $OPCAO_POS_CLONE in
        1)
            iniciar_bot "$AMBIENTE_PATH"
            ;;
        2)
            instalar_modulos "$AMBIENTE_PATH"
            ;;
        0)
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            ;;
        *)
            echo -e "${RED}❌ Opção inválida. Tente novamente.${NC}"
            pos_clone_menu "$AMBIENTE_PATH"
            ;;
    esac
}

# ###########################################
# Função para instalar módulos
# - Propósito: Garante que as dependências necessárias para o bot sejam instaladas.
# ###########################################
instalar_modulos() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "INSTALAR MÓDULOS"
    echo -e "${CYAN}======================================${NC}"

    echo -e "${YELLOW}1 - Instalar com npm install${NC}"
    echo -e "${YELLOW}2 - Instalar com yarn install${NC}"
    echo -e "${RED}0 - Voltar ao menu do ambiente${NC}"
    read -p "> " OPCAO_MODULOS

    case $OPCAO_MODULOS in
        1)
            echo -e "${CYAN}Instalando módulos com npm...${NC}"
            cd "$AMBIENTE_PATH" && npm install > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Módulos instalados com sucesso!${NC}"
            else
                echo -e "${RED}❌ Erro ao instalar módulos com npm. Verifique o arquivo package.json.${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}Instalando módulos com yarn...${NC}"
            cd "$AMBIENTE_PATH" && yarn install > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Módulos instalados com sucesso!${NC}"
            else
                echo -e "${RED}❌ Erro ao instalar módulos com yarn. Verifique o arquivo package.json.${NC}"
            fi
            ;;
        0)
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            ;;
        *)
            echo -e "${RED}❌ Opção inválida. Tente novamente.${NC}"
            instalar_modulos "$AMBIENTE_PATH"
            ;;
    esac

    # Redireciona ao menu do ambiente após a operação
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}

# ###########################################
# Função para iniciar o bot
# - Propósito: Inicia o bot com base nas configurações do ambiente.
# ###########################################
iniciar_bot() {
    AMBIENTE_PATH=$1

    # Exibe as opções de inicialização
    echo -e "${CYAN}Escolha como deseja iniciar o bot:${NC}"
    echo -e "${GREEN}1 - Inicialização padrão - npm start${NC}"
    echo -e "${GREEN}2 - Especificar arquivo (ex: index.js ou start.sh)${NC}"
    echo -e "${GREEN}3 - Instalar módulos e executar o bot${NC}"
    echo -e "${GREEN}4 - Instalar módulos específicos e executar o bot${NC}"
    echo -e "${YELLOW}5 - Ativar bot em segundo plano (background)${NC}"
    echo -e "${RED}0 - Voltar${NC}"
    read -p "> " INICIAR_OPCAO

    case $INICIAR_OPCAO in
        1)
            COMANDO="npm start"
            ;;
        2)
            echo -e "${YELLOW}Digite o nome do arquivo para executar:${NC}"
            read ARQUIVO
            if [[ $ARQUIVO == *.sh ]]; then
                COMANDO="sh $ARQUIVO"
            else
                COMANDO="node $ARQUIVO"
            fi
            ;;
        3)
            verificar_node_modules "$AMBIENTE_PATH"
            COMANDO="npm start"
            ;;
        4)
            instalar_modulos_especificos "$AMBIENTE_PATH"
            COMANDO="npm start"
            ;;
        5)
            echo -e "${YELLOW}Ativando bot em segundo plano...${NC}"
            COMANDO="npm start"
            nohup sh -c "cd $AMBIENTE_PATH && $COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &
            echo "$COMANDO" > "${AMBIENTE_PATH}/.session"
            atualizar_status "$AMBIENTE_PATH" "ON"
            echo -e "${GREEN}Bot ativado em segundo plano com sucesso!${NC}"
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            return
            ;;
        0)
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            return
            ;;
        *)
            echo -e "${RED}Opção inválida.${NC}"
            iniciar_bot "$AMBIENTE_PATH"
            return
            ;;
    esac

    # Executa o bot em primeiro plano para permitir interação inicial
    echo -e "${CYAN}Iniciando o bot... Aguarde o QR Code ou outras instruções.${NC}"
    cd "$AMBIENTE_PATH" || return
    eval "$COMANDO"  # Executa o bot em primeiro plano

    # Após a execução do bot, retorna ao menu principal
    echo -e "${YELLOW}Pressione Enter para voltar ao menu principal...${NC}"
    read
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}
# ###########################################
# Função para instalar módulos específicos
# - Propósito: Permite ao usuário instalar pacotes personalizados separados por vírgula.
# ###########################################
instalar_modulos_especificos() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "INSTALAR MÓDULOS ESPECÍFICOS"
    echo -e "${CYAN}======================================${NC}"

    echo -e "${YELLOW}Escolha o gerenciador de pacotes:${NC}"
    echo -e "${GREEN}1 - npm${NC}"
    echo -e "${GREEN}2 - yarn${NC}"
    echo -e "${RED}0 - Voltar${NC}"
    read -p "> " GERENCIADOR

    case $GERENCIADOR in
        1)
            GERENCIADOR_CMD="npm install"
            ;;
        2)
            GERENCIADOR_CMD="yarn add"
            ;;
        0)
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            return
            ;;
        *)
            echo -e "${RED}❌ Opção inválida.${NC}"
            instalar_modulos_especificos "$AMBIENTE_PATH"
            return
            ;;
    esac

    echo -e "${YELLOW}Digite os pacotes que deseja instalar (separados por vírgula):${NC}"
    echo -e "${CYAN}Exemplo: express,lodash${NC}"
    read PACOTES

    # Converte os pacotes em um array
    IFS=',' read -ra PACOTES_ARRAY <<< "$PACOTES"

    echo -e "${CYAN}Verificando pacotes antes da instalação...${NC}"
    PACOTES_INVALIDOS=()
    for PACOTE in "${PACOTES_ARRAY[@]}"; do
        PACOTE=$(echo "$PACOTE" | xargs)  # Remove espaços extras
        if ! npm show "$PACOTE" > /dev/null 2>&1; then
            PACOTES_INVALIDOS+=("$PACOTE")
        fi
    done

    if [ ${#PACOTES_INVALIDOS[@]} -gt 0 ]; then
        echo -e "${RED}⚠️ Os seguintes pacotes não foram encontrados ou são inválidos:${NC}"
        for PACOTE in "${PACOTES_INVALIDOS[@]}"; do
            echo -e "${RED}- $PACOTE${NC}"
        done
        echo -e "${YELLOW}Deseja continuar a instalação mesmo assim? (sim/não)${NC}"
        read -p "> " CONTINUAR
        if [ "$CONTINUAR" != "sim" ]; then
            echo -e "${RED}Instalação cancelada.${NC}"
            gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
            return
        fi
    fi

    echo -e "${CYAN}Instalando pacotes...${NC}"
    cd "$AMBIENTE_PATH" || return
    for PACOTE in "${PACOTES_ARRAY[@]}"; do
        PACOTE=$(echo "$PACOTE" | xargs)  # Remove espaços extras
        echo -e "${CYAN}Instalando $PACOTE...${NC}"
        if $GERENCIADOR_CMD "$PACOTE" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $PACOTE instalado com sucesso!${NC}"
        else
            echo -e "${RED}❌ Erro ao instalar $PACOTE.${NC}"
            echo -e "${YELLOW}Deseja forçar a instalação usando --force? (sim/não)${NC}"
            read -p "> " FORCAR
            if [ "$FORCAR" = "sim" ]; then
                echo -e "${CYAN}Forçando a instalação de $PACOTE...${NC}"
                if $GERENCIADOR_CMD "$PACOTE" --force > /dev/null 2>&1; then
                    echo -e "${GREEN}✅ $PACOTE instalado com sucesso usando --force.${NC}"
                else
                    echo -e "${RED}❌ Falha ao forçar a instalação de $PACOTE.${NC}"
                fi
            fi
        fi
    done

    echo -e "${YELLOW}Deseja voltar ao menu do ambiente? (sim/não)${NC}"
    read -p "> " VOLTAR
    if [ "$VOLTAR" = "sim" ]; then
        gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
    else
        instalar_modulos_especificos "$AMBIENTE_PATH"
    fi
}
# ###########################################
# Função para parar o bot
# - Propósito: Finaliza o processo do bot em execução em segundo plano.
# ###########################################
parar_bot() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "PARAR O BOT"
    echo -e "${CYAN}======================================${NC}"

    # Verifica se há uma sessão ativa
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        # Finaliza o processo do bot
        echo -e "${YELLOW}Finalizando o processo do bot...${NC}"
        pkill -f "$COMANDO" 2>/dev/null

        # Remove os arquivos de sessão e logs
        rm -f "${AMBIENTE_PATH}/.session"
        rm -f "${AMBIENTE_PATH}/nohup.out"

        # Atualiza o status para OFF
        atualizar_status "$AMBIENTE_PATH" "OFF"

        echo -e "${GREEN}Bot parado com sucesso.${NC}"
        echo -e "${YELLOW}Você pode reiniciar o servidor quando necessário.${NC}"
    else
        echo -e "${RED}Nenhuma sessão ativa encontrada para parar.${NC}"
    fi

    # Retorna ao menu do ambiente
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}
# ###########################################
# Função para reiniciar o bot
# - Propósito: Reinicia o processo do bot com base nas configurações do ambiente.
# ###########################################
reiniciar_bot() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "REINICIAR O BOT"
    echo -e "${CYAN}======================================${NC}"

    # Verifica se há uma sessão ativa
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        # Finaliza o processo antigo
        echo -e "${YELLOW}Finalizando o processo antigo do bot...${NC}"
        pkill -f "$COMANDO" 2>/dev/null

        # Remove os arquivos de sessão e logs
        rm -f "${AMBIENTE_PATH}/.session"
        rm -f "${AMBIENTE_PATH}/nohup.out"

        # Aguarda um momento para garantir que o processo foi encerrado
        sleep 2
    fi

    # Inicia o novo processo
    echo -e "${YELLOW}Iniciando o bot novamente...${NC}"
    COMANDO="npm start"
    cd "$AMBIENTE_PATH" || return
    nohup sh -c "$COMANDO" > "${AMBIENTE_PATH}/nohup.out" 2>&1 &

    # Salva o comando no arquivo .session
    echo "$COMANDO" > "${AMBIENTE_PATH}/.session"

    # Atualiza o status para ON
    atualizar_status "$AMBIENTE_PATH" "ON"

    echo -e "${GREEN}Bot reiniciado com sucesso.${NC}"
    echo -e "${YELLOW}O bot está rodando em segundo plano.${NC}"

    # Retorna ao menu do ambiente
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}
# ###########################################
# Função para visualizar o terminal
# - Propósito: Permite visualizar os logs gerados pelo bot.
# - Editar:
#   * Ajustar mensagens exibidas.
#   * Não alterar a lógica para evitar erros ao acessar os logs.
# ###########################################
ver_terminal() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "VISUALIZAR O TERMINAL"
    echo -e "${CYAN}======================================${NC}"

    # Verifica se há uma sessão ativa
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")
        STATUS=$(recuperar_status "$AMBIENTE_PATH")

        if [ "$STATUS" = "ON" ]; then
            echo -e "${YELLOW}Uma sessão ativa foi encontrada. Finalizando a sessão antes de visualizar os logs...${NC}"
            pkill -f "$COMANDO" 2>/dev/null
            atualizar_status "$AMBIENTE_PATH" "OFF"
            sleep 2
        fi
    fi

    # Verifica se o arquivo de logs existe
    if [ -f "${AMBIENTE_PATH}/nohup.out" ]; then
        clear
        echo -e "${YELLOW}Visualizando os logs em tempo real. Pressione Ctrl+C para voltar ao menu.${NC}"
        echo -e "${CYAN}======================================${NC}"
        tail -f "${AMBIENTE_PATH}/nohup.out"

        # Após sair da visualização, retorna ao menu do ambiente
        echo -e "${CYAN}Saindo da visualização de logs...${NC}"
        gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
    else
        echo -e "${RED}Nenhuma saída encontrada para o terminal.${NC}"
        gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
    fi
}

# ###########################################
# Função para deletar a sessão
# - Propósito: Remove o arquivo de sessão associado ao bot e finaliza o processo em execução.
# ###########################################
deletar_sessao() {
    AMBIENTE_PATH=$1

    echo -e "${CYAN}======================================${NC}"
    anima_texto "DELETAR SESSÃO"
    echo -e "${CYAN}======================================${NC}"

    # Verifica se há uma sessão ativa
    if [ -f "${AMBIENTE_PATH}/.session" ]; then
        COMANDO=$(cat "${AMBIENTE_PATH}/.session")

        # Finaliza o processo do bot
        echo -e "${YELLOW}Finalizando o processo do bot...${NC}"
        pkill -f "$COMANDO" 2>/dev/null

        # Remove os arquivos de sessão e logs
        rm -f "${AMBIENTE_PATH}/.session"
        rm -f "${AMBIENTE_PATH}/nohup.out"

        # Atualiza o status para OFF
        atualizar_status "$AMBIENTE_PATH" "OFF"

        echo -e "${GREEN}Sessão deletada com sucesso.${NC}"
        echo -e "${YELLOW}Por favor, reinicie seu servidor para dar efeito.${NC}"
    else
        echo -e "${RED}Nenhuma sessão ativa encontrada para deletar.${NC}"
    fi

    # Retorna ao menu do ambiente
    gerenciar_ambiente "$(basename "$AMBIENTE_PATH" | sed 's/ambiente//')"
}

# ###########################################
# Função para gerenciar ambiente
# - Propósito: Fornece um menu interativo para gerenciar um ambiente específico.
# ###########################################
gerenciar_ambiente() {
    # Define o caminho do ambiente com base no índice
    AMBIENTE_PATH="${BASE_DIR}/ambiente$1"

    # Recupera o status do ambiente
    STATUS=$(recuperar_status "$AMBIENTE_PATH")

    # Define o indicador visual de status (círculo colorido)
    if [ "$STATUS" = "ON" ]; then
        INDICADOR_STATUS="${GREEN}●${NC}"
    else
        INDICADOR_STATUS="${RED}●${NC}"
    fi

    # Verifica se os arquivos /proc estão disponíveis
    if [ -f "/proc/stat" ] && [ -f "/proc/meminfo" ]; then
        # Calcula o uso de CPU
        CPU_INFO=$(grep '^cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f%%", usage}')

        # Calcula o uso de RAM
        MEM_TOTAL=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
        MEM_FREE=$(grep 'MemFree' /proc/meminfo | awk '{print $2}')
        MEM_USED=$((MEM_TOTAL - MEM_FREE))
        MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))  # Uso de RAM em porcentagem
        MEM_USED_MB=$((MEM_USED / 1024))           # Converte KB para MB
        RAM_INFO="${MEM_USAGE}% (${MEM_USED_MB} MB)"
    else
        # Define valores padrão se /proc não estiver disponível
        CPU_INFO="N/A"
        RAM_INFO="N/A"
        echo -e "${YELLOW}AVISO: Os arquivos /proc não estão disponíveis neste sistema.${NC}"
        echo -e "${YELLOW}Uso de CPU e RAM não pode ser calculado.${NC}"
    fi

    # Cabeçalho do menu
    echo -e "${CYAN}======================================${NC}"
    echo -e "${CYAN}GERENCIANDO AMBIENTE $1${NC}"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}Status do Ambiente: ${INDICADOR_STATUS} (${STATUS})${NC}"
    echo -e "${YELLOW}Uso de CPU: ${CYAN}${CPU_INFO}${NC}"
    echo -e "${YELLOW}Uso de RAM: ${CYAN}${RAM_INFO}${NC}"
    echo -e "${CYAN}--------------------------------------${NC}"

    # Opções do menu
    echo -e "${YELLOW}1 - ESCOLHER BOT PRONTO DA VORTEXUS${NC}"
    echo -e "${YELLOW}2 - INICIAR O BOT ${INDICADOR_STATUS}${NC}"
    echo -e "${YELLOW}3 - PARAR O BOT${NC}"
    echo -e "${YELLOW}4 - REINICIAR O BOT${NC}"
    echo -e "${YELLOW}5 - VISUALIZAR O TERMINAL${NC}"
    echo -e "${YELLOW}6 - DELETAR SESSÃO${NC}"
    echo -e "${YELLOW}7 - REMOVER BOT ATUAL${NC}"
    echo -e "${YELLOW}8 - CLONAR REPOSITÓRIO${NC}"
    echo -e "${RED}0 - VOLTAR${NC}"

    # Recebe a opção do usuário
    read -p "> " OPCAO

    # Switch para redirecionar para a função correspondente
    case $OPCAO in
        1) 
            # Escolher bot pronto
            escolher_bot_pronto "$AMBIENTE_PATH"
            ;;
        2) 
            # Iniciar o bot
            iniciar_bot "$AMBIENTE_PATH"
            ;;
        3) 
            # Parar o bot
            parar_bot "$AMBIENTE_PATH"
            ;;
        4) 
            # Reiniciar o bot
            reiniciar_bot "$AMBIENTE_PATH"
            ;;
        5) 
            # Visualizar o terminal
            ver_terminal "$AMBIENTE_PATH"
            ;;
        6) 
            # Deletar sessão
            deletar_sessao "$AMBIENTE_PATH"
            ;;
        7) 
            # Remover bot atual
            remover_bot "$AMBIENTE_PATH"
            ;;
        8) 
            # Clonar repositório
            clonar_repositorio "$AMBIENTE_PATH"
            ;;
        0) 
            # Voltar ao menu principal
            menu_principal
            ;;
        *) 
            # Opção inválida
            echo -e "${RED}Opção inválida.${NC}"
            gerenciar_ambiente "$1"
            ;;
    esac
}

# Execução principal
exibir_termos
criar_pastas
verificar_sessoes
menu_principal
#verificar_whitelist
