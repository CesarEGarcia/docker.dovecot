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
mv auth-passwdfile.conf.ext auth-passwdfile.conf.ext.bak
touch auth-passwdfile.conf.ext

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
echo "
service imap-login {
    inet_listener imap {
        #port = 143
    }

    inet_listener imaps {
        #port = 993
        #ssl = yes
    }
}
" >> 10-master.conf

echo "
service pop3-login {
    inet_listener pop3 {
        #port = 110
    }
    inet_listener pop3s {
        #port = 995
        #ssl = yes
    }
}
" >> 10-master.conf

echo "
service lmtp {

    # process_min_avail = 5

    inet_listener lmtp {
        port = 24
    }
}
" >> 10-master.conf

echo "
service auth {
    unix_listener auth-userdb {
        #mode = 0666
        #user =
        #group =
    }

    inet_listener {
        port = 26
    }
}
" >> 10-master.conf


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
