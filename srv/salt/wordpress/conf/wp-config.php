<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
/* If you modify this, also modify it from pillars. */
define( 'DB_NAME', "doot");

/** Database username */
define( 'DB_USER', "dootwordpress" );

/** Database password */
define( 'DB_PASSWORD', "YHP71Bnk0vHQpzwkNCVnkw2FKITviePNcr5vQjZhIRc" );

/** Database hostname */
define( 'DB_HOST', "10.0.0.11" );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'l/IZ;*(i7A=Oz1?*#e[hC?=_|V#c|bWq+X8jL4A4;%{[}DYe}ij$5jSvr`eV3!]+');
define('SECURE_AUTH_KEY',  '%a4AUF3MKwES_P,:UKU1J*>;IbB.)h`SAd)TyTUp%l/KDbS?lrYI?4 ?N36*tb+:');
define('LOGGED_IN_KEY',    's1jXiIi^aDfh}?o+C|(^C|wk!p/V!mjpk0`tN^F<[7}(]QRv2?9Pjd5I_3Bg3lFU');
define('NONCE_KEY',        '93f[uKOAOu,Cju^XL/t+?a,9D*m|J%(%`>4`L4IoI}yP+xs&Ul%Sr_|0$9{;S$pU');
define('AUTH_SALT',        'n^TzwJ+G#DeF||7XQZBeK0rV0i+QLlS_Ty8o77q,pRoacu}iDjHhD1NR)cI ZzXS');
define('SECURE_AUTH_SALT', 'M&@A`;oRd}Y_qd![V73EZjO|KT#8sklT:ge~td|oe-|%.+GDiM%5:<dHzV2PiuoE');
define('LOGGED_IN_SALT',   ']Ied)Tn|?3>(iZN&^buFb_Ki+@~DZtPKWq4L+)b20gBj4%=-X(vz]T}`M(N*jDJ>');
define('NONCE_SALT',       '(?-8j?.sI>V_@%QIYWc/N7x]uJCb/%yEPOmpl>Jb4!d_LIS_lcftl^orU0C{2u.0');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
