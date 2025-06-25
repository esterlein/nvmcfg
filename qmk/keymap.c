#include QMK_KEYBOARD_H

// Layer definitions
enum layers {
    _BASE = 0,
    _LOWER,
    _RAISE
};

// Layer tap definitions
#define LT1_TAB LT(_LOWER, KC_TAB)
#define LT2_BSPC LT(_RAISE, KC_BSPC)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /*
     * Base Layer (QWERTY)
     * ┌───┬───┬───┬───┬───┬───┐       ┌───┬───┬───┬───┬───┬───┐
     * │ESC│ Q │ W │ E │ R │ T │       │ Y │ U │ I │ O │ P │DEL│
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │SUP│ A │ S │ D │ F │ G │       │ H │ J │ K │ L │ ; │ ' │
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │SFT│ Z │ X │ C │ V │ B │       │ N │ M │ , │ . │ / │SFT│
     * └───┴───┴───┼───┼───┼───┤       ├───┼───┼───┼───┴───┴───┘
     *             │CTL│ENT│TAB│       │BSP│SPC│CTL│
     *             └───┴───┴───┘       └───┴───┴───┘
     */
    [_BASE] = LAYOUT_split_3x6_3(
        LALT_T(KC_ESC), KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                           KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_DEL,
        KC_LGUI,        KC_A,    KC_S,    KC_D,    KC_F,    KC_G,                           KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
        KC_LSFT,        KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                           KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_RSFT,
                                          KC_LCTL, KC_ENT,  LT1_TAB,                        LT2_BSPC, KC_SPC, KC_RCTL
    ),

    /*
     * Lower Layer (Numbers/Symbols)
     * ┌───┬───┬───┬───┬───┬───┐       ┌───┬───┬───┬───┬───┬───┐
     * │   │ ! │ @ │ # │ $ │ % │       │ ^ │ & │ * │ ( │ ) │   │
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │   │ 1 │ 2 │ 3 │ 4 │ 5 │       │ 6 │ 7 │ 8 │ 9 │ 0 │   │
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │   │ ~ │ ` │ _ │ [ │ { │       │ } │ ] │ - │ + │ = │   │
     * └───┴───┴───┼───┼───┼───┤       ├───┼───┼───┼───┴───┴───┘
     *             │   │   │   │       │   │   │   │
     *             └───┴───┴───┘       └───┴───┴───┘
     */
    [_LOWER] = LAYOUT_split_3x6_3(
        KC_TRNS, LSFT(KC_1), LSFT(KC_2), LSFT(KC_3), LSFT(KC_4), LSFT(KC_5),                LSFT(KC_6), LSFT(KC_7), LSFT(KC_8), LSFT(KC_9), LSFT(KC_0), KC_TRNS,
        KC_TRNS, KC_1,       KC_2,       KC_3,       KC_4,       KC_5,                       KC_6,       KC_7,       KC_8,       KC_9,       KC_0,       KC_TRNS,
        KC_TRNS, LSFT(KC_GRV), KC_GRV,   LSFT(KC_MINS), KC_LBRC, LSFT(KC_LBRC),             LSFT(KC_RBRC), KC_RBRC, KC_MINS,    KC_PLUS,    KC_EQL,     KC_TRNS,
                                         KC_TRNS,    KC_TRNS,    KC_TRNS,                    KC_TRNS,    KC_TRNS,    KC_TRNS
    ),

    /*
     * Raise Layer (Function keys/Navigation)
     * ┌───┬───┬───┬───┬───┬───┐       ┌───┬───┬───┬───┬───┬───┐
     * │   │F1 │F2 │F3 │F4 │F5 │       │F7 │F8 │F9 │F10│F11│F12│
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │   │HOM│   │   │   │PgU│       │ ← │ ↓ │ ↑ │ → │ | │   │
     * ├───┼───┼───┼───┼───┼───┤       ├───┼───┼───┼───┼───┼───┤
     * │   │END│   │   │   │PgD│       │CAP│   │   │   │ \ │   │
     * └───┴───┴───┼───┼───┼───┤       ├───┼───┼───┼───┴───┴───┘
     *             │   │   │   │       │   │   │   │
     *             └───┴───┴───┘       └───┴───┴───┘
     */
    [_RAISE] = LAYOUT_split_3x6_3(
        KC_TRNS, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,                              KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,
        KC_TRNS, KC_HOME, KC_NO,   KC_NO,   KC_NO,   KC_PGUP,                            KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, LSFT(KC_BSLS), KC_TRNS,
        KC_TRNS, KC_END,  KC_NO,   KC_NO,   KC_NO,   KC_PGDN,                            KC_CAPS, KC_NO,   KC_NO,   KC_NO,   KC_BSLS, KC_TRNS,
                                   KC_TRNS, KC_TRNS, KC_TRNS,                            KC_TRNS, KC_TRNS, KC_TRNS
    )
};

#ifdef ENCODER_ENABLE

bool encoder_update_user(uint8_t index, bool clockwise)
{
    switch (get_highest_layer(layer_state)) {
        case _BASE:
        case _LOWER:
        case _RAISE:
            if (clockwise) {
                tap_code(KC_VOLU);
            } else {
                tap_code(KC_VOLD);
            }
            break;
        default:
            if (clockwise) {
                rgblight_increase_hue();
            } else {
                rgblight_decrease_hue();
            }
            break;
    }
    return false;
}
#endif
