Ti.include('env.js')
describe "cloudinary", ->
  cloudinary = require '/lib/cloudinary'
  beforeEach ->
    cloudinary.config cloud_name: "test123"

  it "should use cloud_name from config", ->
    result = cloudinary.utils.url("test")
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/test"

  it "should allow overriding cloud_name in options", ->
    options = cloud_name: "test321"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test321/image/upload/test"

  it "should use format from options", ->
    options = format: "jpg"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/test.jpg"

  it "should default to akamai if secure is given with private_cdn and no secure_distribution", ->
    options = secure: true, private_cdn: true
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "https://test123-res.cloudinary.com/image/upload/test"

  it "should not add cloud_name if secure private_cdn and secure non akamai secure_distribution", ->
    options = secure: true, private_cdn: true, secure_distribution: "something.cloudfront.net"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "https://something.cloudfront.net/image/upload/test"

  it "should not add cloud_name if private_cdn and not secure", ->
    options = private_cdn: true
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://test123-res.cloudinary.com/image/upload/test"

  it "should use width and height from options only if crop is given", ->
    options =
      width: 100
      height: 100

    result = cloudinary.utils.url("test", options)
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/h_100,w_100/test"
    expect(options).toEqual
      width: 100
      height: 100

    options =
      width: 100
      height: 100
      crop: "crop"

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual
      width: 100
      height: 100

    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test"


  it "should not pass width and height to html in case of fit or limit crop", ->
    options =
      width: 100
      height: 100
      crop: "limit"

    result = cloudinary.utils.url("test", options)
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_limit,h_100,w_100/test"
    expect(options).toEqual {}

    options =
      width: 100
      height: 100
      crop: "fit"

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}

    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test"

  it "should not pass width and height to html in case angle was used", ->
    options =
      width: 100
      height: 100
      crop: "scale"
      angle: "auto"

    result = cloudinary.utils.url("test", options)
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/a_auto,c_scale,h_100,w_100/test"
    expect(options).toEqual {}

  it "should use x, y, radius, opacity, prefix, gravity and quality from options", ->
    options =
      x: 1
      y: 2
      radius: 3
      gravity: "center"
      quality: 0.4
      prefix: "a"
      opacity: 20

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/g_center,o_20,p_a,q_0.4,r_3,x_1,y_2/test"

  it "should support named tranformation", ->
    options = transformation: "blip"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/t_blip/test"

  it "should support array of named tranformations", ->
    options = transformation: [ "blip", "blop" ]
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/t_blip.blop/test"

  it "should support base tranformation", ->
    options =
      transformation:
        x: 100
        y: 100
        crop: "fill"

      crop: "crop"
      width: 100

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual width: 100
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/c_crop,w_100/test"

  it "should support array of base tranformations", ->
    options =
      transformation: [{x: 100, y: 100, width: 200, crop: "fill"} , {radius: 10} ]
      crop: "crop"
      width: 100

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual width: 100
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_fill,w_200,x_100,y_100/r_10/c_crop,w_100/test"

  it "should not include empty tranformations", ->
    options = transformation: [ {}, {x: 100, y: 100, crop: "fill"} , {} ]
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/test"

  it "should support size", ->
    options =
      size: "10x10"
      crop: "crop"

    result = cloudinary.utils.url("test", options)
    expect(options).toEqual
      width: "10"
      height: "10"

    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/c_crop,h_10,w_10/test"

  it "should use type from options", ->
    options = type: "facebook"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/facebook/test"

  it "should use resource_type from options", ->
    options = resource_type: "raw"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/raw/upload/test"

  it "should ignore http links only if type is not given or is asset", ->
    options = type: null
    result = cloudinary.utils.url("http://example.com/", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://example.com/"
    options = type: "asset"
    result = cloudinary.utils.url("http://example.com/", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://example.com/"
    options = type: "fetch"
    result = cloudinary.utils.url("http://example.com/", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/fetch/http://example.com/"

  it "should escape fetch urls", ->
    options = type: "fetch"
    result = cloudinary.utils.url("http://blah.com/hello?a=b", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/fetch/http://blah.com/hello%3Fa%3Db"

  it "should escape http urls", ->
    options = type: "youtube"
    result = cloudinary.utils.url("http://www.youtube.com/watch?v=d9NF2edxy-M", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/youtube/http://www.youtube.com/watch%3Fv%3Dd9NF2edxy-M"

  it "should support background", ->
    options = background: "red"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/b_red/test"
    options = background: "#112233"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/b_rgb:112233/test"

  it "should support default_image", ->
    options = default_image: "default"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/d_default/test"

  it "should support angle", ->
    options = angle: 12
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/a_12/test"

  it "should support format for fetch urls", ->
    options =
      format: "jpg"
      type: "fetch"

    result = cloudinary.utils.url("http://cloudinary.com/images/logo.png", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/fetch/f_jpg/http://cloudinary.com/images/logo.png"

  it "should support effect", ->
    options = effect: "sepia"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/e_sepia/test"

  it "should support effect with param", ->
    options = effect: [ "sepia", 10 ]
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/e_sepia:10/test"

  layers =
    overlay: "l"
    underlay: "u"

  for layer of layers
    it "should support #{layer}", ->
      options = {}
      options[layer] = "text:hello"
      result = cloudinary.utils.url("test", options)
      expect(options).toEqual {}
      expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/#{layers[layer]}_text:hello/test"

    it "should not pass width/height to html for #{layer}", ->
      options =
        height: 100
        width: 100

      options[layer] = "text:hello"
      result = cloudinary.utils.url("test", options)
      expect(options).toEqual {}
      expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/h_100,#{layers[layer]}_text:hello,w_100/test"

  it "should correctly sign api requests", ->
    expect(cloudinary.utils.api_sign_request({hello: null, goodbye: 12, world: "problem"}, "1234")).toEqual "f05cfe85cee78e7e997b3c7da47ba212dcbf1ea5"

  it "should correctly build signed preloaded image", ->
    expect(cloudinary.utils.signed_preloaded_image(
      resource_type: "image"
      version: 1251251251
      public_id: "abcd"
      format: "jpg"
      signature: "123515adfa151"
    )).toEqual "image/upload/v1251251251/abcd.jpg#123515adfa151"

  it "should support density", ->
    options = density: 150
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/dn_150/test"

  it "should support page", ->
    options = page: 5
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/pg_5/test"

  it "should support extenal cname", ->
    options = cname: "hello.com"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://hello.com/test123/image/upload/test"

  it "should support extenal cname with cdn_subdomain on", ->
    options = cname: "hello.com", cdn_subdomain: true
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://a2.hello.com/test123/image/upload/test"

  it "should support border", ->
    options = border: {width: 5}
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/bo_5px_solid_black/test"
    options = border: {width: 5, color: "#ffaabbdd"}
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/bo_5px_solid_rgb:ffaabbdd/test"
    options = border: "1px_solid_blue"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/bo_1px_solid_blue/test"

  it "should support flags", ->
    options = flags: "abc"
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/fl_abc/test"
    options = flags: ["abc", "def"]
    result = cloudinary.utils.url("test", options)
    expect(options).toEqual {}
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/fl_abc.def/test"

  it "should add version if public_id contains /", ->
    result = cloudinary.utils.url("folder/test")
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/v1/folder/test"
    result = cloudinary.utils.url("folder/test", version: 123)
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/v123/folder/test"

  it "should not add version if public_id contains version already", ->
    result = cloudinary.utils.url("v1234/test")
    expect(result).toEqual "http://res.cloudinary.com/test123/image/upload/v1234/test"

  it "should allow to shorted image/upload urls", ->
    result = cloudinary.utils.url("test", shorten: true)
    expect(result).toEqual "http://res.cloudinary.com/test123/iu/test"

