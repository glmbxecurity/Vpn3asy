opcion=0
while [ $opcion -ne 8 ]
do
clear


#recolectar los ficheros .ovpn
ovpn_files=$(ls *.ovpn)

echo ""
echo "		#################################################"
echo "		#						#"
echo "		#		     VPN3ASY			#"
echo "		#						#"
echo "		#	     CONEXION FACIL Y SEGURA		#"
echo "		#		    A VPN DE			#"
echo "		#   	      TRYHACKME Y HACKTHEBOX		#"
echo "		#						#"
echo "		#################################################"
echo
echo "			https://GlmbXecurity.gitbub.io"
echo
echo
echo "==================================================================================="
echo "- Reglas iptables gracias a Wh1teDrvg0n"
echo "- RECUERDA tener el fichero .ovpn en el MISMO DIRECTORIO que este SCRIPT"
echo "- IMPORTANTE ejecutar el script con permisos de ADMINISTRADOR"
echo "==================================================================================="
echo
echo "QUE QUIERES HACER?"
echo
echo "1. Conexión simple a VPN"
echo "2. Conexión SEGURA a VPN"
echo
echo "3. BACKUP configuración firewall"
echo "4. RESTORE configuración firewall"
echo "5. Flush Firewall"
echo "6. COMPROBAR configuración firewall"
echo
echo "7. Explícame en que consiste la conexión de forma segura"
echo "8. Salir"
echo
    read -p "Selecciona una opción (1-6): " opcion

    case $opcion in
    
        1)  	#Conexion vpn sin reglas de firewall
        	clear
        	echo "Estos son los ficheros .ovpn encontrados en : $(pwd)"
        	echo "========================================================"
        	
		ls | grep -nE '.ovpn' | sed 's/:/ /' | awk '{print $2}'
		echo
        	read -p "Escribe el nombre del fichero que quieres usar para la conexion VPN: " ovpn
        	openvpn --config $ovpn

		;; 
            
            
        2)  	
        
        	#conexion vpn con reglas de firewall
        	clear
        	echo "Realizando backup de tu configuración iptables"
        	iptables-save > ./backup_iptables.txt
        	sleep 1
        	echo
        	echo "Backup realizado en:"
        	echo "$(pwd)/$(ls backup*)"
        	echo
       		read -p "Introduce la IP de la Máquina (Tryhackme o HTB) a la que quieres permitir el tráfico de entrada: " ipmaquina
       		echo "IP introducida: "$ipmaquina
       		echo
       		read -p "Si es correcto, pulsa cualquier tecla para continuar, sino pulsa Ctrl+C para salir" nulo
       		echo
       		echo "configurando iptables..."
       		sleep 1

						# IPv4 flush
						iptables -P INPUT ACCEPT
						iptables -P FORWARD ACCEPT
						iptables -P OUTPUT ACCEPT
						iptables -t nat -F
						iptables -t mangle -F
						iptables -F
						iptables -X
						iptables -Z

						 # IPv6 flush
						ip6tables -P INPUT DROP
						ip6tables -P FORWARD DROP
						ip6tables -P OUTPUT DROP
						ip6tables -t nat -F
						ip6tables -t mangle -F
						ip6tables -F
						ip6tables -X
						ip6tables -Z

						 # Ping machine
						iptables -A INPUT -p icmp -i tun0 -s $ipmaquina --icmp-type echo-request -j ACCEPT
						iptables -A INPUT -p icmp -i tun0 -s $ipmaquina --icmp-type echo-reply -j ACCEPT
						iptables -A INPUT -p icmp -i tun0 --icmp-type echo-request -j DROP  
						iptables -A INPUT -p icmp -i tun0 --icmp-type echo-reply -j DROP
						iptables -A OUTPUT -p icmp -o tun0 -d $ipmaquina --icmp-type echo-reply -j ACCEPT
						iptables -A OUTPUT -p icmp -o tun0 -d $ipmaquina --icmp-type echo-request -j ACCEPT
						iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-request -j DROP
						iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-reply -j DROP

						 # Allow VPN connection only from machine
						iptables -A INPUT -i tun0 -p tcp -s $ipmaquina -j ACCEPT
						iptables -A OUTPUT -o tun0 -p tcp -d $ipmaquina -j ACCEPT
						iptables -A INPUT -i tun0 -p udp -s $ipmaquina -j ACCEPT
						iptables -A OUTPUT -o tun0 -p udp -d $ipmaquina -j ACCEPT
						iptables -A INPUT -i tun0 -j DROP
						iptables -A OUTPUT -o tun0 -j DROP
		
		echo "Iptables configurado con éxito!"
		sleep 1
       		clear
		
		echo "Estos son los ficheros .ovpn encontrados en : $(pwd)"
        	echo "========================================================"
        	
		ls | grep -nE '.ovpn' | sed 's/:/ /' | awk '{print $2}'
		echo
        	read -p "Escribe el nombre del fichero que quieres usar para la conexion VPN: " ovpn
        	openvpn --config $ovpn
        	echo "Conexión realizada a VPN con el fichero $ovpn"
        ;;
        
        
        3)	#backup reglas firewall
        	clear
        	echo "Realizando backup de tu configuración iptables"
        	iptables-save > ./backup_iptables.txt
        	sleep 1
        	echo
        	echo "Backup realizado en:"
        	echo "$(pwd)/$(ls backup*)"
        	echo ""
        	echo "Resumen del backup"
        	echo "==============================================="
        	echo
        	iptables -L
        	echo "==============================================="
        	echo ""
        	read -p "Pulsa cualquier tecla para volver al menú, o Ctrl+C para salir del programa " nulo
        	echo
            
            ;;
        4)   #Restaurar backup
		clear
		echo "Resumen del fichero $(pwd)/$(ls backup*): "
		echo "==============================================="
		echo
		cat ./backup_iptables.txt
		echo "==============================================="
		echo
		read -p "Estás seguro de que quieres restaurar el backup? (Intro para continuar, Ctrl+C para salir) " nulo
            	iptables-restore < ./backup_iptables.txt
            	;;
         
        5)  #Flush iptables
            clear
            echo "Realizando un flush Iptables..."
            sleep 1
            					# IPv4 flush
						iptables -P INPUT ACCEPT
						iptables -P FORWARD ACCEPT
						iptables -P OUTPUT ACCEPT
						iptables -t nat -F
						iptables -t mangle -F
						iptables -F
						iptables -X
						iptables -Z

						 # IPv6 flush
						ip6tables -P INPUT DROP
						ip6tables -P FORWARD DROP
						ip6tables -P OUTPUT DROP
						ip6tables -t nat -F
						ip6tables -t mangle -F
						ip6tables -F
						ip6tables -X
						ip6tables -Z
		echo "Flush realizado con exito!"				
		read -p "Pulsa cualquier tecla para volver al menú, o Ctrl+C para salir del programa " nulo
                ;;
                            
            
            
        6)	#Comprobar estado del firewall
        	clear
        	echo "Resumen de la configuración actual del firewall"
        	echo "==============================================="
        	echo
        	iptables -L
        	read -p "Pulsa cualquier tecla para volver al menú, o Ctrl+C para salir del programa " nulo
            
            ;;
    
        7)  	#Info sobre conexion segura
        	clear
        
        	"Al ejecutar la conexion VPN de forma segura, lo que se está haciendo es crear unas reglas de IPtables, que solo permitirán 
             	las conexiones entrantes DESDE la maquina a la que nos vamos a conectar. Las conexiones salientes no se verán afectadas, por 
           	lo que se puede navegar por internet sin ningún problema. Pero recuerda, es recomendable devolver el firewall a su estado original 
           	para evitar problemas de conexiones futuras. "
            	echo
            	read -p "Pulsa cualquier tecla para volver al menú, o Ctrl+C para salir del programa " nulo
            	;;
            
        8) 	#salida del programa
        	clear
        	echo "Gracias por usar el script de GlmbXecurity!"
            	sleep 1
            	exit
        	;;
        *)	#opcion erronea
            echo "Opción inválida. Por favor, selecciona una opción válida del menú. "
            sleep 2
            ;;
      esac
      
done
