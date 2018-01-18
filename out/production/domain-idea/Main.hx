package ;
import tink.core.Future;
using tink.CoreApi;

class Main
{
    var resultList:Array<String> = [];

    static var vowels = ["a", "e", "i", "o", "u"];
    static var consonants = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"];
    static var all = vowels.concat(consonants);
    static var ending = ["ful", "ic", "ous", "ive", "y", "acy", "al", "ance", "ence", "dom", "er", "or", "ism", "ist", "ity", "ty", "ment", "ness", "ship", "sion", "tion", "ion" ];

    var map = ["V" => vowels,
               "C" => consonants,
               "A" => all,
               "E" => ending];

    public static function main()
    {
        new Main();
    }

    public function new()
    {
       parse("CVCVsoul.com", false);
    }

    function parse(base:String, isFast)
    {
        var found = false;
        for ( i in 0...base.length )
        {
            if (map.exists(base.charAt(i)))
            {
                for (j in map.get(base.charAt(i)))
                {
                    var newBaseArr = base.split("");
                    newBaseArr[i] = j;
                    parse(newBaseArr.join(""), isFast);
                    found = true;
                }
            }
        }

        if (!found)
        {
            lookup(base, isFast).handle( function(o)
            {
                switch ( o )
                {
                    case Success(domain): trace(domain);
                    default:
                }
            });
        }
    }

    function lookup(domain, isFast)
    {
        return Future.async(function( handler )
            lookupNative(domain, isFast, handler)
        );

    }

    function lookupNative(domain, isFast, handler)
    {
        Dns.resolve4(domain, function (err, data)
        {
            if ( err != null || data == null || data.length == 0 )
            {
                if ( isFast )
                    handler(Success(domain));
                else
                    lookupWhoisNative(domain, handler);
            }
        });
    }

    function lookupWhoisNative(domain, handler)
    {
        Whois.lookup(domain, function(err, data)
        {
            trace(domain);
            if ( err != null || data == null || data.indexOf("You have reached configured rate limit") != -1 )
                lookupWhoisNative(domain, handler);
            else if ( data.indexOf("No match for domain") != -1 )
                handler(Success(domain));
            else
                handler(Failure("taken"));
        });
    }
}

@:jsRequire("dns")
extern class Dns
{
    static function resolve4(domain:String, callback:js.Error->Array<String>->Void):Void;
}

@:jsRequire("whois")
extern class Whois
{
    static function lookup(domain:String, callback:js.Error->String->Void):Void;
}