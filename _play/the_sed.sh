#!/usr/bin/env bash

WP_CFG_AUTH_KEY='/lfo*+;/u5K=4Pz./^Y};6=hiPS`HF]9E}}~cXc,U6v_`,Zr_W<a$eFH*5~/eg*Q'
WP_CFG_SECURE_AUTH_KEY='@?og|h/NHU4pF],616GW>nHhNRJj-d%4mvK|b/8$YSu9U%8u`/ZrG.EjY5r){|;M'
WP_CFG_LOGGED_IN_KEY='-k`|P;^#-kS|2c1k;mi>SB,#h<jy?r}F[#;`ZE@Hx^uIGE;C_U&]|#yuC2xQg^yG'
WP_CFG_NONCE_KEY='PU?|algD|<N7eid]}`t/jX#`AwfsM%TZamt}5ZG:u%tw5K!=+x~cn|7Amd_teJzW'
WP_CFG_AUTH_SALT='zfX160ANsN+<oOU[dX2{:2J(fW_FFWajZ3KX~Je(KQVPU/$&.C!RrTdh?If~Ix_3'
WP_CFG_SECURE_AUTH_SALT='|p@%dG1~5Zcfado!cx[+?k#ZYd]:i%Jn1/6`!)p.%`!MtK+E$S87a%1$$c2]GU_G'
WP_CFG_LOGGED_IN_SALT='tO6qB?`|K^qo%S]Wg* P<tz;3xR<Mda0?DghIe~89Mx x9lhJ(4k2K8#z>)6,>_X'
WP_CFG_NONCE_SALT='^u}xLH :|A%^_5Gp5NVviZ)UVR7!)A]Ep{<nZ{Nq<&a;.YnW)#Qag3???zTQ|G!R'

function entry_msg () {
  echo "[wp-entrypoint.sh] $1"
}

function escape_sed() {
  echo "$1" | sed 's/[][}{}^/()$&.*+?|]/\\&/g'
}

do_the_crazy_sed () {
  local key_name=$1
  local escaped_key_content="$(escape_sed "$2")"
  entry_msg "sedding: $key_name"
  entry_msg "escaped_key_content: $escaped_key_content"
  sed "s|define( '$key_name', \+'put your unique phrase here' );|define( '$key_name', '$escaped_key_content');|g" ./wpcfg.php
}

do_the_crazy_sed "AUTH_KEY" "$WP_CFG_AUTH_KEY"
do_the_crazy_sed "SECURE_AUTH_KEY" "$WP_CFG_SECURE_AUTH_KEY"
do_the_crazy_sed "LOGGED_IN_KEY" "$WP_CFG_LOGGED_IN_KEY"
do_the_crazy_sed "NONCE_KEY" "$WP_CFG_NONCE_KEY"
do_the_crazy_sed "AUTH_SALT" "$WP_CFG_AUTH_SALT"
do_the_crazy_sed "SECURE_AUTH_SALT" "$WP_CFG_SECURE_AUTH_SALT"
do_the_crazy_sed "LOGGED_IN_SALT" "$WP_CFG_LOGGED_IN_SALT"
do_the_crazy_sed "NONCE_SALT" "$WP_CFG_NONCE_SALT"



