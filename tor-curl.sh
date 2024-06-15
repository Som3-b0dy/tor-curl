#!/bin/bash

source settings.cfg

arg_num="$#"
file_name="$0"
first_arg="$1"

check_input() {
    if [ "$arg_num" != 1 ]; then
        echo -e "${BOLD_RED}[!]${NC} Input one argument"
        print_help "$file_name"
    else
        case "$first_arg" in
            -h)
                print_help "$file_name"
                ;;
            -c)
                check_ip
                ;;
            -k)
                kill_ip
                ;;
            *)
                tor_curl "$first_arg"
                ;;
        esac
    fi
}

check_tor_ports() {
    check_ports=$(ss -tln | grep -e "$SocksPort" -e "$ControlPort" | wc -l)
    check_tor=$(sudo systemctl is-active tor)
    if [ $check_tor != "active" ]; then
        echo -e "${BOLD_RED}[!]${NC} Start tor service"
        echo -e "${BOLD}[$]${NC} sudo systemctl start tor"
    fi
    if [[ $check_ports != 2 && $check_tor = "active" ]]; then
        echo -e "${BOLD_RED}[!]${NC} Add necessary settings to $Torrc"
        echo -e "${BOLD}[+]${NC} For example:"
        printf -- "-> SocksPort=9050\n-> ControlPort=9051\n"
        echo -e "${BOLD_RED}[!]${NC} Restart tor service"
        echo -e "${BOLD}[$]${NC} sudo systemctl restart tor"
    fi
}

check_ip() {
    curl --socks5-hostname 127.0.0.1:9050 https://api.ipify.org/
}

kill_ip() {
    echo -e 'AUTHENTICATE ""\r\nsignal NEWNYM\r\nQUIT' | nc 127.0.0.1 9051
}

tor_curl() {
    curl --socks5-hostname 127.0.0.1:9050 "$first_arg"
}

print_help() {
    echo -e "${BOLD_RED}[!]${NC} Usage: $0 <target_url>"
    echo "Curl through tor"
    printf -- "-h -> print this menu\n-c -> check my IP\n-k -> kill current IP"
}

check_input "$arg_num" "$file_name" "$first_arg"
check_tor_ports