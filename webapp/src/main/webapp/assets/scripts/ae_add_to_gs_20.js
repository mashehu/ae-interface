/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

(function($, undefined) {
    if($ == undefined)
        throw "jQuery not loaded";

    function
    gsLoggedIn( gs_username )
    {
        alert("Logged in as " + gs_username);
        retrieveGSPersonalDirectory();
    }

    function
    gsLoggedOut()
    {
        alert("Not logged in");
    }

    function
    checkIfLoggedToGS( onLoggedInFunc, onLoggedOutFunc )
    {
        $.ajax({
            url : "https://identity.genomespace.org/identityServer/usermanagement/utility/token/username"
            , xhrFields: { withCredentials: true }
            , success : onLoggedInFunc
            , error : onLoggedOutFunc
        });
    }

    function
    retrieveGSPersonalDirectory()
    {
        $.ajax({
            url : "https://dm.genomespace.org/datamanager/v1.0/personaldirectory"
            , xhrFields: { withCredentials: true }
            , success : function(json) {
                alert(json.directory.path);
            }
            , dataType: "json"
        });

    }


    $(function() {
        checkIfLoggedToGS(gsLoggedIn, gsLoggedOut);
    });

})(window.jQuery);