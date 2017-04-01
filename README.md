# ansible-container

Freifunk in Containern

## Einführung

Diese Ansible-Playbooks konfigurieren einen oder mehrere Server für die Ausführung von Docker Containern, erstellen die notwendigen Konfigurationen und starten Container.

## Voraussetzungen

Es wird unterschieden zwischen den Servern, auf denen Ansible seine Tasks ausführt und einer Control Machine, von der aus Ansible selber aufgerufen wird.

### Server

Unterstützt werden folgende Distributionen:

* Ubuntu 12.04+
* Debian 8.5+

Eine Minimalinstallation ist ausreichend, allerdings werden folgende Pakete für Ansible auf dem Server benötigt:

* sudo
* python2.7

### Control Machine

Auf der Control Machine wird eine aktuelle Ansible Installation (>=2.2) vorausgesetzt.

Außerdem sollte von der Control Machine eine Anmeldung an alle Server ohne Passwort (SSH key authentication) möglich sein, um nicht bei jedem Ansible Run das Passwort angeben zu müssen.


## Tags

| Tag   | Aufgabe                                                 |
| ----- | ------------------------------------------------------- |
| setup | Pakete installieren, Keys und Konfigurationen erstellen |
| start | Docker-Netzwerke vorbereiten, Docker-Container starten  |

## Rollen / Container

### `tinc` (Server VPN)

`tinc` ist ein VPN-Daemon, der eine Bridge zwischen allen Freifunk-Servern aufbaut; diese Bridge wird auf allen Servern
als Batman-Interface verwendet, so dass die Freifunk Server im Mesh direkt miteinander verbunden sind.

#### Ansible

* setup

  * Erstellt Private und Public Key
  * Kopiert Host-Konfiguration auf alle Freifunk-Knoten
  * Kopiert Host-Konfiguration optional auf weitere Server (zur Verbindung mit bereits vorhandenen Systemen)

* start

  * Startet den `tinc` Container

##### Templates

* ``host_config.j2``

  Konfigurationsdatei, die in ``/etc/tinc/hosts/`` für alle Server erstellt wird; enthält Zieladresse und Public-Key

#### Dockerimage

##### Funktion

Der Container ermittelt beim Start automatisch alle Dateinamen aus ``/etc/tinc/hosts`` und trägt diese als Ziele in der
``tinc.conf`` in die Direktive ``ConnectTo`` ein (ausgenommen ``TINC_NAME``).

##### Konfiguration

###### /etc/tinc/tinc.conf

* Wird aus ``/etc/tinc/tinc.conf.in`` beim Starten generiert (wenn vorhanden)
* Durch Mounten des Verzeichnisses ``/etc/tinc`` kann man eine komplett eigene Konfiguration verwenden

| Umgebungsvariable       | `tinc`-Option     | Default                                                 |
| ----------------------- | ----------------- | ------------------------------------------------------- |
| ``TINC_NAME``           | ``Name``          | ``unknown``                                             |
| ``TINC_ADDRESS_FAMILY`` | ``AddressFamily`` | ``ipv4``                                                |
| ``TINC_DEVICE``         | ``Device``        | ``/dev/net/tun``                                        |
| ``TINC_MODE``           | ``Mode``          | ``switch``                                              |
| ``TINC_CONNECT_TO``     | ``ConnectTo``     | alle Ziele aus ``/etc/tinc/hosts/`` außer ``TINC_NAME`` |
| ``TINC_CONFIG_APPEND``  |                   | Wird an das Ende des Templates angehängt                |

###### Volumes

* ``/etc/tinc/rsa_key.priv``

  Private Key

* ``/etc/tinc/rsa_key.pub``

  Public Key

* ``/etc/tinc/hosts/``

  Verzeichnis mit Konfigurationen der beteiligten Server

###### Netzwerk

* *Host-Netzwerk*
* Verwendet das Interface ``tap0``

### fastd (Node VPN)

VPN für Freifunk-Nodes

### dhcp

Verteilt die DHCP-Adressen für einen Adressbereich / ein Gateway

### gateway-ipv4

Baut GRE-Tunnel auf und startet bird, konfiguriert das IP-Forwarding

### recursor

Stellt einen DNS-Resolver zur Verfügung
