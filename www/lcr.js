var exec = require('cordova/exec');

exports.scan = function (str_close, str_scaning, camera_num, str_scaning_size, scanstring_flash, str_custom_image, show_switch_btn, success, error) {
    exec(success, error, 'lcr', 'scan', [str_close, str_scaning, camera_num, str_scaning_size, scanstring_flash, str_custom_image, show_switch_btn]);
};
