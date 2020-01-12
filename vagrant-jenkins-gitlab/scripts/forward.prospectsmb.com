$ORIGIN prospectsmb.com.
$TTL 86400
@   IN  SOA server1.prospectsmb.com. root.prospectsmb.com. (
        2020010701   ; serial
        3600         ; refresh
        1800         ; retry
        604800       ; expire
        86400 )      ; minimum TTL
;
; define nameservers
    IN  NS  ns1.prospectsmb.com.
    IN  NS  ns2.prospectsmb.com.
;
; IP address and hostname
ns1 IN  A  10.1.42.161
ns2 IN  A  10.1.42.162
;
;client records
app   IN  A   10.1.42.151
app   IN  A   10.1.42.152
core  IN  A   10.1.42.151
core  IN  A   10.1.42.152
