/* #####################################################################
   #
   #   Project       : Modal Login with jQuery Effects
   #   Author        : Rodrigo Amarante (rodrigockamarante)
   #   Version       : 1.0
   #   Created       : 07/29/2015
   #   Last Change   : 08/04/2015
   #
   ##################################################################### */
// import axios from 'axios';
$(function () {

    var $formLogin = $('#login-form');
    var $formLost = $('#lost-form');
    var $formRegister = $('#register-form');
    var $divForms = $('#div-forms');
    var $modalAnimateTime = 300;
    var $msgAnimateTime = 150;
    var $msgShowTime = 2000;

    $("form").submit(function (e) {
        e.preventDefault();
        switch (this.id) {
            case "login-form":

                var $lg_usercred = $('#login_usercred').val();
                var $lg_password = $('#login_password').val();
                // if ($lg_usercred == "ERROR") {
                //     msgChange($('#div-login-msg'), $('#icon-login-msg'), $('#text-login-msg'), "error", "glyphicon-remove", "Login error");
                // } else {
                //     msgChange($('#div-login-msg'), $('#icon-login-msg'), $('#text-login-msg'), "success", "glyphicon-ok", "Login OK");
                // }
                var request = new Request('https://api.projectmito.io/v1/sessions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    mode: 'cors',
                    body: JSON.stringify({
                        'usercred': $lg_usercred,
                        'password': $lg_password
                    }),
                    cache: 'default'
                });

                fetch(request)
                    .then(function (response) {
                        if (response.status >= 300) {

                            return response.text().then(function (err) {
                                console.log("Response Error: " + err);
                                Promise.reject(err);
                            });

                        } else {
                            localStorage.setItem('authorization', response.headers.get('Authorization'));
                            console.log('successfullt login');
                        }
                    })
                    .catch(function (err) {
                        console.log("Fetch Error: " + err);
                    });
                return false;
                break;

            case "register-form":
                var $rg_userfname = $('#register_userfname').val();
                var $rg_userlname = $('#register_userlname').val();
                var $rg_username = $('#register_username').val();
                var $rg_email = $('#register_email').val();
                var $rg_password = $('#register_password').val();
                var $rg_passwordconf = $('#register_passwordconf').val();
                var $rg_userdob = $('#register_userdob').val();
                // console.log($rg_username)
                // if ($rg_username == "ERROR") {
                //     msgChange($('#div-register-msg'), $('#icon-register-msg'), $('#text-register-msg'), "error", "glyphicon-remove", "Register error");
                // } else {
                //     msgChange($('#div-register-msg'), $('#icon-register-msg'), $('#text-register-msg'), "success", "glyphicon-ok", "Register OK");
                // }

                var request = new Request('https://api.projectmito.io/v1/users/validate', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    mode: 'cors',
                    body: JSON.stringify({
                        'userFname': $rg_userfname,
                        'userLname': $rg_userlname,
                        'username': $rg_username,
                        'userEmail': $rg_email,
                        'password': $rg_password,
                        'passwordConf': $rg_passwordconf,
                        "userDOB": $rg_userdob
                    }),
                    cache: 'default'
                });

                fetch(request)
                    .then(function (response) {
                        if (response.status >= 300) {
                            return response.text().then(function (err) {
                                console.log("Response Error: " + err);
                                let errorMessage = err.toString();
                                var errorMessageElement = document.getElementById("error-message")

                                if (errorMessage.includes("password must be atleast 6 characters")) {
                                    errorMessageElement.innerHTML = "Password must be atleast 6 characters long";
                                } else if (errorMessage.includes("passwords do not match")) {
                                    errorMessageElement.innerHTML = "Passwords do not match";
                                } else if (errorMessage.includes("email already exists")) {
                                    errorMessageElement.innerHTML = "Email already exists";
                                } else if (errorMessage.includes("username already exists")) {
                                    errorMessageElement.innerHTML = "Username already exists";
                                } else if (errorMessage.includes("invalid email")) {
                                    errorMessageElement.innerHTML = "Invalid Email";
                                }
                                errorMessageElement.style.visibility = "visible";

                                Promise.reject(err);
                            });
                        } else {
                            localStorage.setItem('authorization', response.headers.get('Authorization'));
                            document.getElementById("register_userfname").value = "";
                            document.getElementById("register_userlname").value = "";
                            document.getElementById("register_username").value = "";
                            document.getElementById("register_email").value = "";
                            document.getElementById("register_password").value = "";
                            document.getElementById("register_passwordconf").value = "";
                            document.getElementById("register_userdob").value = "";
                            $('#login-modal').modal('hide');
                            // alert('Thank you');
                            console.log('successfully made an account');
                            $('#completion-modal').modal('show');
                            var request = new Request('https://api.projectmito.io/v1/email', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                mode: 'cors',
                                body: JSON.stringify({
                                    'email': $rg_email,
                                    'firstName': $rg_userfname
                                }),
                                cache: 'default'
                            });

                            fetch(request)
                                .then(function (response) {
                                    console.log(response);
                                })
                                .catch(function (err) {
                                    console.log(err);
                                });
                        }

                    })
                    .catch(function (err) {
                        console.log("Fetch Error: " + err);
                    });
                return false;
                break;
            default:
                return false;
        }
        return false;
    });

    $('#nav-signup').click(function () {
        var elementSignup = document.getElementById("register-form");
        var elementLogin = document.getElementById("login-form");
        $divForms.css("height", "658px");
        elementLogin.style.display = 'none';
        elementSignup.style.display = 'block';

    });
    $('#nav-login').click(function () {
        var elementSignup = document.getElementById("register-form");
        var elementLogin = document.getElementById("login-form");
        $divForms.css("height", "375px");
        elementSignup.style.display = 'none';
        elementLogin.style.display = 'block';

    });
    $('#login_register_btn').click(function () { modalAnimate($formLogin, $formRegister) });
    $('#register_login_btn').click(function () { modalAnimate($formRegister, $formLogin); });
    // $('#nav-signup').click(function () { modalAnimate($formLogin, $formRegister); });
    function modalAnimate($oldForm, $newForm) {
        var $oldH = $oldForm.height();
        var $newH = $newForm.height();
        $divForms.css("height", $oldH);
        $oldForm.fadeToggle($modalAnimateTime, function () {
            $divForms.animate({ height: $newH }, $modalAnimateTime, function () {
                $newForm.fadeToggle($modalAnimateTime);
            });
        });
    }

    function msgFade($msgId, $msgText) {
        $msgId.fadeOut($msgAnimateTime, function () {
            $(this).text($msgText).fadeIn($msgAnimateTime);
        });
    }

    function msgChange($divTag, $iconTag, $textTag, $divClass, $iconClass, $msgText) {
        var $msgOld = $divTag.text();
        msgFade($textTag, $msgText);
        $divTag.addClass($divClass);
        $iconTag.removeClass("glyphicon-chevron-right");
        $iconTag.addClass($iconClass + " " + $divClass);
        setTimeout(function () {
            msgFade($textTag, $msgOld);
            $divTag.removeClass($divClass);
            $iconTag.addClass("glyphicon-chevron-right");
            $iconTag.removeClass($iconClass + " " + $divClass);
        }, $msgShowTime);
    }
});