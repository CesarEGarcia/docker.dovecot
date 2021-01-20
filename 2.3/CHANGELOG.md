- 2.3.11.3-2
    Activar lda_mailbox_autosuscribe en 15-lda.conf
    Activar lda_mailbox_autocreate en 15-lda.conf
    REPLICATION="no" | "yes"
    REPLICATION_SERVER="tcp:mailbackup.ametel.es:10005"
    USERDB="/opt/dovecot/conf/passwords/%d"

- 2.3.11.3-1
    SIEVE_BEFORE="PATH global sieve script file"
    SIEVE_LOG="no" | "yes"
        Si quiere activar el log del sieve

    Actualizar a https://pigeonhole.dovecot.org/releases/2.3/dovecot-2.3-pigeonhole-0.5.11.tar.gz
    Actualizar a dovecot 2.3.11.3

- 2.3.7.2-6
    BACKUP_SERVER="tcp:backup.existo.net:10005"
    Servidor de backup

- 2.3.7.2-5
    QUOTA_SERVICE="no" | "yes"
    Si activa el servicio de quota para consultar desde postfix, por defecto no

    QUOTA_SERVICE_PORT="10001"
    Puerto del servicio de quotas, por defecto 10001

    QUOTA=""
    Cuota definida por defecto, por defecto nada