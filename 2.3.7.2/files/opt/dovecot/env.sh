#!/bin/bash
# 10-auth.conf
# disable_plaintext_auth = yes no permite autenticacion sin SSL
# disable_plaintext_auth = no permite autenticacion sin SSL
#

cd /opt/dovecot/etc/dovecot/conf.d

if [ -f env.sh ]; then
    exit 0
fi

mv 10-master.conf 10-master.bak
touch 10-master.conf
mv 20-submission.conf 20-submission.bak
touch 20-submission.conf
mv auth-passwdfile.conf.ext auth-passwdfile.conf.ext.bak
touch auth-passwdfile.conf.ext


################
# dovecot.conf
################
echo "" >> ../local.conf
echo "protocols = ${PROTOCOLS}" >> ../local.conf
echo "" >> ../local.conf


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
    echo -e "-tunix_listener auth-userdb {" >> 10-master.conf
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
    sed 's|ssl_cert =.*|#ssl_cert = </etc/ssl/certs/dovecot.pem|' -i 10-ssl.conf
    sed 's|ssl_key =.*|#ssl_key = </etc/ssl/private/dovecot.pem|' -i 10-ssl.conf
fi


################
# 20-lmtp.conf
################
sed 's/#lmtp_proxy = no/lmtp_proxy = yes/' -i 20-lmtp.conf


######################
# 20-submission.conf
######################

echo "" >> 20-submission.conf
echo "hostname = ${NAME}" >> 20-submission.conf
echo "submission_client_workarounds = whitespace-before-path" >> 20-submission.conf
# echo "submission_client_workarounds = whitespace-before-path mailbox-for-path" >> 20-submission.conf
echo "submission_relay_host = ${SUBMISSION_HOST}" >> 20-submission.conf
echo "submission_relay_port = 25" >> 20-submission.conf
echo "submission_relay_trusted = yes" >> 20-submission.conf
echo "" >> 20-submission.conf
echo "" >> 20-submission.conf
if [ "$SUBMISSION" = "yes" ]; then
    echo "protocol submission {" >> 20-submission.conf
    echo "}" >> 20-submission.conf
fi
echo "" >> 20-submission.conf
echo "" >> 20-submission.conf


############################
# auth-passwdfile.conf.ext
############################
sed 's|args = scheme=CRYPT username_format=%u /etc/dovecot/users|args = scheme=CRYPT username_format=%u /opt/dovecot/conf/passwords/%d|' -i auth-passwdfile.conf.ext
sed 's|args = username_format=%u /etc/dovecot/users|args = username_format=%u /opt/dovecot/conf/passwords/%d|' -i auth-passwdfile.conf.ext
echo "
passdb {
  driver = passwd-file
  args = scheme=CRYPT username_format=%u /opt/dovecot/conf/passwords/%d
}

userdb {
  driver = passwd-file
  args = username_format=%u /opt/dovecot/conf/passwords/%d
}

passdb {
  driver = passwd-file
  args = /opt/dovecot/conf/passwords/master
  master = yes
  pass = yes
}

passdb {
    driver = passwd-file
    args = /opt/dovecot/conf/passwords/master
    master = yes
    pass = yes
}

auth_master_user_separator = *

" >> auth-passwdfile.conf.ext

echo "#Ya configurado" > env.sh

#############
exit 0
