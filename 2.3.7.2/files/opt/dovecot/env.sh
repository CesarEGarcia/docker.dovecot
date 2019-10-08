#!/bin/bash
# 10-auth.conf
# disable_plaintext_auth = yes no permite autenticacion sin SSL
# disable_plaintext_auth = no permite autenticacion sin SSL
#

cd /opt/dovecot/etc/dovecot/conf.d

if [ -f env.sh ]; then
    exit 0
fi

mkdir bak
mv 10-master.conf bak/10-master.bak
touch 10-master.conf
mv 20-submission.conf bak/20-submission.bak
touch 20-submission.conf
mv auth-passwdfile.conf.ext bak/auth-passwdfile.conf.ext.bak
touch auth-passwdfile.conf.ext
mv 20-imap.conf bak/20-imap.conf.bak
mv 20-lmtp.conf bak/20-lmtp.conf.bak
mv 20-pop3.conf bak/20-pop3.conf.bak


################
# dovecot.conf
################
sed 's/^#protocols =.*/protocols = /' -i ../dovecot.conf


################
# 10-auth.conf
################
sed 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/' -i 10-auth.conf
sed 's/^auth_mechanisms =.*/auth_mechanisms = plain login/' -i 10-auth.conf
sed 's/!include auth-system.conf.ext/#!include auth-system.conf.ext/' -i 10-auth.conf
sed 's/#!include auth-passwdfile.conf.ext/!include auth-passwdfile.conf.ext/' -i 10-auth.conf


###################
# 10-logging.conf
###################
sed 's|#log_path =.*|log_path = /var/log/dovecot/'${NAME}'.dovecot.log|' -i 10-logging.conf
sed 's|#info_log_path =.*|info_log_path = /var/log/dovecot/'${NAME}'.dovecot-info.log|' -i 10-logging.conf
sed 's|#log_path =.*|log_path = /var/log/dovecot/= mail.midominio.com SSL = no AUTH_DEBUG = no AUTH_DEBUG_PASSWORDS = no.dovecot.log|' -i /opt/dovecot/etc/dovecot/conf.d/10-logging.conf
sed 's/#auth_verbose = no/auth_verbose = yes/' -i 10-logging.conf
sed 's/#auth_verbose_passwords = no/auth_verbose_passwords = yes/' -i 10-logging.conf

if [ "$AUTH_DEBUG" = "yes" ]; then
    sed 's/#auth_debug = no/auth_debug = yes/' -i 10-logging.conf
fi
if [ "$AUTH_DEBUG_PASSWORDS" = "yes" ]; then
    sed 's/#auth_debug_passwords = no/auth_debug_passwords= yes/' -i 10-logging.conf
fi


################
# 10-mail.conf
################
sed 's|#mail_location =|mail_location = mdbox:~/mdbox|' -i 10-mail.conf


##################
# 10-master.conf
##################
echo "" >> 10-master.conf
echo "service imap-login {" >> 10-master.conf
echo -e "\tservice_count = 0" >> 10-master.conf
echo -e "\tprocess_min_avail = 4" >> 10-master.conf
echo -e "\tvsz_limit = 1G" >> 10-master.conf
echo -e "\tinet_listener imap {" >> 10-master.conf

if [ "$IMAP" = "yes" ]; then
    echo -e "\t\tport = 143" >> 10-master.conf
else
    echo -e "\t\tport = 0" >> 10-master.conf
fi

echo -e "\t}" >> 10-master.conf
echo -e "\tinet_listener imaps {" >> 10-master.conf

if [ "$IMAPS" = "yes" ]; then
    echo -e "\t\tport = 993" >> 10-master.conf
else
    echo -e "\t\tport = 0" >> 10-master.conf
fi

echo -e "\t\tssl = yes" >> 10-master.conf
echo -e "\t}" >> 10-master.conf
echo -e "}" >> 10-master.conf

echo "" >> 10-master.conf
echo "" >> 10-master.conf

echo "service pop3-login {" >> 10-master.conf
echo -e "\tservice_count = 0" >> 10-master.conf
echo -e "\tinet_listener pop3 {" >> 10-master.conf
if [ "$POP3" = "yes" ]; then
    echo -e "\t\tport = 110" >> 10-master.conf
else
    echo -e "\t\tport = 0" >> 10-master.conf
fi

echo -e "\t}" >> 10-master.conf
echo -e "\tinet_listener pop3s {" >> 10-master.conf
if [ "$POP3S" = "yes" ]; then
    echo -e "\t\tport = 995" >> 10-master.conf
else
    echo -e "\t\tport = 0" >> 10-master.conf
fi
echo -e "\t\tssl = yes" >> 10-master.conf
echo -e "\t}" >> 10-master.conf
echo -e "}" >> 10-master.conf

echo "" >> 10-master.conf
echo "" >> 10-master.conf

echo -e "service lmtp {" >> 10-master.conf
echo -e "\t# process_min_avail = 5" >> 10-master.conf
echo -e "\tinet_listener lmtp {" >> 10-master.conf
if [ "$LMTP" = "yes" ]; then
    echo -e "\t\tport = 24" >> 10-master.conf
else
    echo -e "\t\tport = 0" >> 10-master.conf
fi
echo -e "\t}" >> 10-master.conf
echo -e "}" >> 10-master.conf

echo "" >> 10-master.conf
echo "" >> 10-master.conf

if [ "$AUTH" = "yes" ]; then
    echo -e "service auth {" >> 10-master.conf
    echo -e "\tunix_listener auth-userdb {" >> 10-master.conf
    echo -e "\t\t#mode = 0666" >> 10-master.conf
    echo -e "\t\t#user =" >> 10-master.conf
    echo -e "\t\t#group =" >> 10-master.conf
    echo -e "\t}" >> 10-master.conf
    echo -e "" >> 10-master.conf
    echo -e "\tinet_listener {" >> 10-master.conf
    echo -e "\t\tport = 26" >> 10-master.conf
    echo -e "\t}" >> 10-master.conf
    echo -e "}" >> 10-master.conf
fi

echo "" >> 10-master.conf
echo "" >> 10-master.conf

echo "
service auth-worker {
}
" >> 10-master.conf

echo "
service dict {
    unix_listener dict {
        #mode = 0600
        #user =
        #group =
    }
}
" >> 10-master.conf


###############
# 10-ssl.conf
###############
if [ "$SSL" = "yes" ]; then
    sed 's/#ssl = yes/ssl = yes/' -i 10-ssl.conf
    sed 's|ssl_cert =.*|ssl_cert = </etc/letsencrypt/live/'${NAME}'/fullchain.pem|' -i 10-ssl.conf
    sed 's|ssl_key =.*|ssl_key = </etc/letsencrypt/live/'${NAME}'/privkey.pem|' -i 10-ssl.conf
else
    sed 's/#ssl = yes/ssl = no/' -i 10-ssl.conf
    sed 's|ssl_cert =.*|#ssl_cert = </etc/ssl/certs/dovecot.pem|' -i 10-ssl.conf
    sed 's|ssl_key =.*|#ssl_key = </etc/ssl/private/dovecot.pem|' -i 10-ssl.conf
fi


################
# 20-imap.conf
################

if [ "$IMAP" = "yes" ] || [ "$IMAPS" = "yes" ]; then
    echo -e "protocols = \$protocols imap" >> 20-imap.conf
    echo -e "" >> 20-imap.conf
    echo -e "protocol imap {" >> 20-imap.conf
    echo -e "}" >> 20-imap.conf
    echo -e "" >> 20-imap.conf
    echo -e "" >> 20-imap.conf
fi


################
# 20-lmtp.conf
################

if [ "$LMTP" = "yes" ]; then
    echo -e "protocols = \$protocols lmtp" >> 20-lmtp.conf
    echo -e "" >> 20-lmtp.conf
    echo -e "lmtp_proxy = yes" >> 20-lmtp.conf
    echo -e "" >> 20-lmtp.conf
    echo -e "" >> 20-lmtp.conf
    echo -e "protocol lmtp {" >> 20-lmtp.conf
    if [ "$SIEVE" = "yes" ]; then
        echo -e "\tmail_plugins = $mail_plugins sieve" >> 20-lmtp.conf
    fi
    echo -e "}" >> 20-lmtp.conf
    echo -e "" >> 20-lmtp.conf
    echo -e "" >> 20-lmtp.conf
fi


#######################
# 20-managesieve.conf
#######################

if [ "$SIEVE" = "yes" ]; then
    echo -e "" >> 20-managesieve.conf
    echo -e "protocols = \$protocols sieve" >> 20-managesieve.conf
    echo -e "" >> 20-managesieve.conf
    echo -e "service managesieve-login {" >> 20-managesieve.conf
    echo -e "\tinet_listener sieve {" >> 20-managesieve.conf
    echo -e "\t\tport = 4190" >> 20-managesieve.conf
    echo -e "\t}" >> 20-managesieve.conf
    echo -e "}" >> 20-managesieve.conf
    echo -e "" >> 20-managesieve.conf
    echo -e "" >> 20-managesieve.conf
    echo -e "service managesieve {" >> 20-managesieve.conf
    echo -e "}" >> 20-managesieve.conf
    echo -e "" >> 20-managesieve.conf
    echo -e "" >> 20-managesieve.conf
fi


################
# 20-pop3.conf
################

if [ "$POP3" = "yes" ] || [ "$POP3S" = "yes" ]; then
    echo -e "protocols = \$protocols pop3" >> 20-pop3.conf
    echo -e "" >> 20-pop3.conf
    echo -e "protocol pop3 {" >> 20-pop3.conf
    echo -e "}" >> 20-pop3.conf
    echo -e "" >> 20-pop3.conf
    echo -e "" >> 20-pop3.conf
fi


######################
# 20-submission.conf
######################

if [ "$SUBMISSION" = "yes" ]; then
    echo "" >> 20-submission.conf
    echo -e "protocols = \$protocols submission" >> 20-managesieve.conf
    echo "" >> 20-submission.conf
    echo "" >> 20-submission.conf
    echo "hostname = ${NAME}" >> 20-submission.conf
    echo "submission_client_workarounds = whitespace-before-path" >> 20-submission.conf
    # echo "submission_client_workarounds = whitespace-before-path mailbox-for-path" >> 20-submission.conf
    echo "submission_relay_host = ${SUBMISSION_HOST}" >> 20-submission.conf
    echo "submission_relay_port = 25" >> 20-submission.conf
    echo "submission_relay_trusted = yes" >> 20-submission.conf
    echo "" >> 20-submission.conf
    echo "" >> 20-submission.conf
    echo "protocol submission {" >> 20-submission.conf
    echo "}" >> 20-submission.conf
    echo "" >> 20-submission.conf
    echo "" >> 20-submission.conf
fi

#######################
# 90-sieve.conf
#######################

if [ "$SIEVE" = "yes" ]; then
    echo -e "" >> 90-sieve.conf
    echo -e "protocol sieve {" >> 90-sieve.conf
    echo -e "\tmanagesieve_max_line_length = 65536" >> 90-sieve.conf
    echo -e "\tmanagesieve_implementation_string = dovecot" >> 90-sieve.conf
    echo -e "\t# log_path = /var/log/dovecot-sieve-errors.log" >> 90-sieve.conf
    echo -e "\t# info_log_path = /var/log/dovecot-sieve.log" >> 90-sieve.conf
    echo -e "}" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
    echo -e "plugin {" >> 90-sieve.conf
    echo -e "\tsieve = ~/dovecot.sieve" >> 90-sieve.conf
    echo -e "\tsieve_global_path = /etc/dovecot/sieve/default.sieve" >> 90-sieve.conf
    echo -e "\tsieve_dir = ~/sieve" >> 90-sieve.conf
    echo -e "\tsieve_global_dir = /etc/dovecot/sieve" >> 90-sieve.conf
    echo -e "}" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
fi


############################
# auth-passwdfile.conf.ext
############################
echo -e ""
echo -e "passdb {" >> auth-passwdfile.conf.ext
echo -e "\tdriver = passwd-file" >> auth-passwdfile.conf.ext
echo -e "\targs = scheme=CRYPT username_format=%u /opt/dovecot/conf/passwords/%d" >> auth-passwdfile.conf.ext
echo -e "}" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext
echo -e "userdb {" >> auth-passwdfile.conf.ext
echo -e "\tdriver = passwd-file" >> auth-passwdfile.conf.ext
echo -e "\targs = username_format=%u /opt/dovecot/conf/passwords/%d" >> auth-passwdfile.conf.ext
echo -e "}" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext

if [ "$MASTER_PASSWORD" = "yes" ]; then
    echo -e "passdb {" >> auth-passwdfile.conf.ext
    echo -e "\tdriver = passwd-file" >> auth-passwdfile.conf.ext
    echo -e "\targs = /opt/dovecot/conf/passwords/master" >> auth-passwdfile.conf.ext
    echo -e "\tmaster = yes" >> auth-passwdfile.conf.ext
    echo -e "\tpass = yes" >> auth-passwdfile.conf.ext
    echo -e "}" >> auth-passwdfile.conf.ext
    echo -e "" >> auth-passwdfile.conf.ext
fi

echo -e "" >> auth-passwdfile.conf.ext
echo -e "auth_master_user_separator = *" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext


chown vmail.vmail /home/dominios

echo "#Ya configurado" > env.sh

#############
exit 0
