#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

	// Layer 0: Base
	[0] = LAYOUT_split_3x6_3(
		LALT_T(KC_ESC), KC_Q, KC_W, KC_E, KC_R, KC_T,              KC_P, KC_O, KC_I, KC_U, KC_Y, KC_NO,
		KC_LGUI,         KC_A, KC_S, KC_D, KC_F, KC_G,              KC_QUOT, KC_SCLN, KC_L, KC_K, KC_J, KC_H,
		KC_LSFT,         KC_Z, KC_X, KC_C, KC_V, KC_B,              KC_RSFT, KC_SLSH, KC_DOT, KC_COMM, KC_M, KC_N,
		                            KC_LCTL, KC_ENT, LT(1, KC_TAB), KC_RCTL, KC_SPC,  LT(2, KC_BSPC)
	),

	// Layer 1: Symbols / Numpad
	[1] = LAYOUT_split_3x6_3(
		KC_TRNS, LSFT(KC_1), LSFT(KC_2), LSFT(KC_3), LSFT(KC_4), LSFT(KC_5),    LSFT(KC_0), LSFT(KC_9), LSFT(KC_8), LSFT(KC_7), LSFT(KC_6), KC_NO,
		KC_TRNS, KC_KP_1,    KC_KP_2,    KC_KP_3,    KC_KP_4,    KC_KP_5,       KC_KP_0,    KC_KP_9,    KC_KP_8,    KC_KP_7,    KC_KP_6, KC_NO,
		KC_TRNS, LSFT(KC_GRAVE), KC_GRAVE, LSFT(KC_MINUS), KC_LBRC, LSFT(KC_LBRC), KC_TRNS, KC_KP_EQUAL, KC_KP_PLUS, KC_KP_MINUS, KC_RBRC, LSFT(KC_RBRC),
		                            KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
	),

	// Layer 2: Navigation / Function keys
	[2] = LAYOUT_split_3x6_3(
		KC_TRNS, KC_F1, KC_F2, KC_F3, KC_F4, KC_F5,        KC_F12, KC_F11, KC_F10, KC_F9, KC_F8, KC_F7,
		KC_TRNS, KC_HOME, KC_NO, KC_NO, KC_NO, KC_PGUP,    LSFT(KC_BSLS), KC_RIGHT, KC_UP, KC_DOWN, KC_LEFT, KC_NO,
		KC_TRNS, KC_END,  KC_NO, KC_NO, KC_NO, KC_PGDN,    KC_TRNS, KC_BSLS, KC_NO, KC_NO, KC_NO, KC_CAPS,
		                           KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS
	),
};
