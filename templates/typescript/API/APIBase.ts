
type Int = number

class ResponceEmpty {

}

class APIRequest<ResponseType,ErrorType> {
    path(): string {
        return ""
    }

    method(): string {
        return "POST"
    }


    public send(onSuccess:(result:ResponseType)=>void, onError:(error:ErrorType)=>void) {
        var xhr = new XMLHttpRequest();
        xhr.open(this.method(), this.path(), true);
        if (onSuccess) xhr.onload = function() { 
            try {
                onSuccess(JSON.parse(this.responseText)); 
            }
            catch (e) {
                
            }
            
        };
    
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify(this));
    }    
}

//-------------------------------------------------
// Simple function to GET or POST
function httpCall(method: string, url:string, data:any, callback:(result:any)=>any) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    if (callback) xhr.onload = function() { callback(JSON.parse(this['responseText'])); };
    if (data != null) {
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify(data));
    }
    else xhr.send();
}