#!/bin/bash
# 10-auth.conf
# disable_plaintext_auth = yes no permite autenticacion sin SSL
# disable_plaintext_auth = no permite autenticacion sin SSL
#
#

cd /opt/dovecot/etc/dovecot/conf.d

if [ -f env.sh ]; then
    if [ "$SIEVE" = "yes" ]; then
        /opt/postfix/bin/postfix -c /opt/postfix/etc start
    fi
    exit 0
fi

mkdir bak
mv 10-mail.conf bak/10-mail.bak
touch 10-mail.conf
mv 10-master.conf bak/10-master.bak
touch 10-master.conf
mv 20-submission.conf bak/20-submission.bak
touch 20-submission.conf
mv auth-passwdfile.conf.ext bak/auth-passwdfile.conf.ext.bak
touch auth-passwdfile.conf.ext
mv 20-imap.conf bak/20-imap.conf.bak
mv 20-lmtp.conf bak/20-lmtp.conf.bak
mv 20-pop3.conf bak/20-pop3.conf.bak
mv 90-quota.conf bak/90-quota.conf.bak
touch 90-quota.conf
[ -f 90-replication.conf ] && rm 90-replication.conf
touch 90-replication.conf


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
if [ "$AUTH_POLICY_SERVER" != "" ]; then
    echo "" >> 10-auth.conf
    echo -e "auth_policy_server_url = ${AUTH_POLICY_SERVER}" >> 10-auth.conf
    echo -e "auth_policy_hash_nonce = localized_random_string" >> 10-auth.conf
    echo -e "auth_policy_check_after_auth = no" >> 10-auth.conf
    echo -e "auth_policy_report_after_auth = yes" >> 10-auth.conf
    echo "" >> 10-auth.conf
fi



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
if [ "$DEBUG" = "yes" ]; then
    echo -e "" >> 10-logging.conf
    echo -e "mail_debug = yes" >> 10-logging.conf
    echo -e "" >> 10-logging.conf
fi

################
# 10-mail.conf
################
echo -e "" >> 10-mail.conf
echo -e "mail_location = mdbox:~/mdbox" >> 10-mail.conf
echo -e "" >> 10-mail.conf
echo -e "namespace inbox {" >> 10-mail.conf
echo -e "\tinbox = yes" >> 10-mail.conf
echo -e "}" >> 10-mail.conf
echo -e "" >> 10-mail.conf
echo -e "mail_plugins = " >> 10-mail.conf
if [ ! -z "$QUOTA" ]; then
    echo -e "" >> 10-mail.conf
    echo -e "mail_plugins = \$mail_plugins quota" >> 10-mail.conf
fi
if [ "$REPLICATION" = "yes" ]; then
    echo -e "" >> 10-mail.conf
    echo -e "mail_plugins = \$mail_plugins notify replication" >> 10-mail.conf
    echo -e "" >> 10-mail.conf
fi
echo "" >> 10-mail.conf
echo "" >> 10-mail.conf



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

echo "" >> 10-master.conf
echo "" >> 10-master.conf

if [ "$DOVEADM" = "yes" ]; then
    echo -e "service doveadm {" >> 10-master.conf
    echo -e "\tinet_listener {" >> 10-master.conf
    echo -e "\t\tport = ${DOVEADM_PORT}" >> 10-master.conf
    echo -e "\t}" >> 10-master.conf
    echo -e "}" >> 10-master.conf
    echo -e "doveadm_password = \"${DOVEADM_PASSWORD}\""  >> 10-master.conf
fi

echo "" >> 10-master.conf
echo "" >> 10-master.conf
echo -e "service dict {" >> 10-master.conf
echo -e "\tunix_listener dict {" >> 10-master.conf
echo -e "\t\t#mode = 0600" >> 10-master.conf
echo -e "\t\t#user =" >> 10-master.conf
echo -e "\t\t#group =" >> 10-master.conf
echo -e "\t}" >> 10-master.conf
echo -e "}" >> 10-master.conf

if [ "$QUOTA_SERVICE" = "yes" ]; then
    echo "" >> 10-master.conf
    echo "" >> 10-master.conf
    echo -e "service quota-status {" >> 10-master.conf
    echo -e "\texecutable = quota-status -p postfix" >> 10-master.conf
    echo -e "\tinet_listener {" >> 10-master.conf
    echo -e "\t\tport = ${QUOTA_SERVICE_PORT}" >> 10-master.conf
    echo -e "\t}" >> 10-master.conf
    echo -e "\tclient_limit = 1" >> 10-master.conf
    echo -e "}" >> 10-master.conf
fi

if [ "$REPLICATION" = "yes" ]; then
    echo "" >> 10-master.conf
    echo "" >> 10-master.conf
    echo -e "service replicator {" >> 10-master.conf
    echo -e "\tprocess_min_avail = 1" >> 10-master.conf
    echo -e "}" >> 10-master.conf
fi

echo "" >> 10-master.conf
echo "" >> 10-master.conf



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


###############
# 15-lda.conf
###############
echo "" >> 15-lda.conf
echo "" >> 15-lda.conf
echo "lda_mailbox_autocreate = yes" >> 15-lda.conf
echo "lda_mailbox_autosubscribe = yes" >> 15-lda.conf
echo "" >> 15-lda.conf
echo "" >> 15-lda.conf


################
# 20-imap.conf
################

if [ "$IMAP" = "yes" ] || [ "$IMAPS" = "yes" ]; then
    echo -e "protocols = \$protocols imap" >> 20-imap.conf
    echo -e "" >> 20-imap.conf
    echo -e "protocol imap {" >> 20-imap.conf
    if [ ! -z "$QUOTA" ]; then
        echo -e "\tmail_plugins = \$mail_plugins imap_quota" >> 20-imap.conf
    fi
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
        echo -e "\tmail_plugins = \$mail_plugins sieve" >> 20-lmtp.conf
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
    echo -e "protocols = \$protocols submission" >> 20--submission.conf
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
# 90-quota.conf
#######################
if [ ! -z "$QUOTA" ]; then
    echo -e "" >> 90-quota.conf
    echo -e "plugin {" >> 90-quota.conf
    echo -e "\tquota = count:User quota" >> 90-quota.conf
    echo -e "\tquota_rule = *:storage=$QUOTA" >> 90-quota.conf
    echo -e "\tquota_vsizes = yes" >> 90-quota.conf
    echo -e "\tquota_grace = 10%%" >> 90-quota.conf
    echo -e "\tquota_status_success = DUNNO" >> 90-quota.conf
    echo -e "\tquota_status_nouser = DUNNO" >> 90-quota.conf
    echo -e "\tquota_status_overquota = \"552 5.2.2 Mailbox is full\"" >> 90-quota.conf
    echo -e "}" >> 90-quota.conf
    echo -e "" >> 90-quota.conf
    echo -e "" >> 90-quota.conf
fi


#######################
# 90-replication.conf
#######################
if [ "$REPLICATION" = "yes" ]; then
    echo -e "" >> 90-replication.conf
    echo -e "service aggregator {" >> 90-replication.conf
    echo -e "\tfifo_listener replication-notify-fifo {" >> 90-replication.conf
    echo -e "\t\tuser = vmail" >> 90-replication.conf
    echo -e "\t}" >> 90-replication.conf
    echo -e "\tunix_listener replication-notify {" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "\t\tuser = vmail" >> 90-replication.conf
    echo -e "\t}" >> 90-replication.conf
    echo -e "}" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "service replicator {" >> 90-replication.conf
    echo -e "\tunix_listener replicator-doveadm {" >> 90-replication.conf
    echo -e "\t\tmode = 0600" >> 90-replication.conf
    echo -e "\t\tuser = vmail" >> 90-replication.conf
    echo -e "\t}" >> 90-replication.conf
    echo -e "\tprocess_min_avail = 1" >> 90-replication.conf
    echo -e "}" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "plugin {" >> 90-replication.conf
    echo -e "\tmail_replica = ${REPLICATION_SERVER}" >> 90-replication.conf
    echo -e "}" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
    echo -e "" >> 90-replication.conf
fi


#######################
# 90-sieve.conf
#######################

if [ "$SIEVE" = "yes" ]; then
    echo -e "" >> 90-sieve.conf
    echo -e "protocol sieve {" >> 90-sieve.conf
    echo -e "\tmanagesieve_max_line_length = 65536" >> 90-sieve.conf
    echo -e "\tmanagesieve_implementation_string = dovecot" >> 90-sieve.conf
    if [ "$SIEVE_LOG" = "yes" ]; then
        echo -e "\tlog_path = /var/log/dovecot/sieve.${NAME}.log" >> 90-sieve.conf
        echo -e "\tinfo_log_path = /var/log/dovecot/sieve-info.${NAME}.log" >> 90-sieve.conf
    fi
    echo -e "}" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
    echo -e "" >> 90-sieve.conf
    echo -e "plugin {" >> 90-sieve.conf
    echo -e "\tsieve = ~/dovecot.sieve" >> 90-sieve.conf
    echo -e "\tsieve_dir = ~/sieve" >> 90-sieve.conf
    if [ ! -z "$SIEVE_BEFORE" ]; then
        echo -e "\tsieve_before = ${SIEVE_BEFORE}" >> 90-sieve.conf
    fi
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
echo -e "\targs = scheme=CRYPT username_format=%u ${USERDB}" >> auth-passwdfile.conf.ext
echo -e "}" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext
echo -e "userdb {" >> auth-passwdfile.conf.ext
echo -e "\tdriver = passwd-file" >> auth-passwdfile.conf.ext
echo -e "\targs = username_format=%u ${USERDB}" >> auth-passwdfile.conf.ext
echo -e "}" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext

if [ "$MASTER_PASSWORD" = "yes" ]; then
    echo -e "passdb {" >> auth-passwdfile.conf.ext
    echo -e "\tdriver = passwd-file" >> auth-passwdfile.conf.ext
    echo -e "\targs = /opt/dovecot/conf/master" >> auth-passwdfile.conf.ext
    echo -e "\tmaster = yes" >> auth-passwdfile.conf.ext
    echo -e "\tresult_success = continue" >> auth-passwdfile.conf.ext
    echo -e "}" >> auth-passwdfile.conf.ext
    echo -e "" >> auth-passwdfile.conf.ext
fi

echo -e "" >> auth-passwdfile.conf.ext
echo -e "auth_master_user_separator = *" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext
echo -e "" >> auth-passwdfile.conf.ext

chown vmail.vmail /home/dominios

if [ "$SIEVE" = "yes" ]; then
    echo -e "maillog_file          = /var/log/dovecot/sieve.postfix.${NAME}.log" >> /opt/postfix/etc/main.cf
    echo -e "relayhost             = ${SIEVE_SMTP}" >> /opt/postfix/etc/main.cf
    echo -e "smtp_sasl_auth_enable = no" >> /opt/postfix/etc/main.cf
    echo -e "" >> /opt/postfix/etc/main.cf
    echo -e "" >> /opt/postfix/etc/main.cf
fi


echo "#Ya configurado" > env.sh

if [ "$SIEVE" = "yes" ]; then
    /opt/postfix/bin/postfix -c /opt/postfix/etc start
fi


###############
exit 0
