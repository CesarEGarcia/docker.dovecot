<<<<<<< HEAD
- 2.3.11.3-2
    REPLICATION="no" | "yes"
    REPLICATION_SERVER="mailbackup.ametel.es:10005"

- 2.3.11.3-1
    SIEVE_BEFORE="PATH global sieve script file"
    SIEVE_LOG="no" | "yes"
        Si quiere activar el log del sieve

    Actualizar a https://pigeonhole.dovecot.org/releases/2.3/dovecot-2.3-pigeonhole-0.5.11.tar.gz
    Actualizar a dovecot 2.3.11.3

=======
- 2.3.7.2-6
    BACKUP_SERVER="tcp:backup.existo.net:10005"
    Servidor de backup
    
>>>>>>> 17ad2dc760f22490aa3ba589a71b1c5db4e162b4
- 2.3.7.2-5
    QUOTA_SERVICE="no" | "yes"
    Si activa el servicio de quota para consultar desde postfix, por defecto no

    QUOTA_SERVICE_PORT="10001"
    Puerto del servicio de quotas, por defecto 10001

    QUOTA=""
    Cuota definida por defecto, por defecto nada