import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'astrology/astronomy_engine.dart';
import 'kundli_page.dart';

class RashiProfilePage extends StatefulWidget {
  const RashiProfilePage({super.key});
  @override
  State<RashiProfilePage> createState() => _RashiProfilePageState();
}
class _RashiProfilePageState extends State<RashiProfilePage> {
  DateTime? dob;
  TimeOfDay? birthTime;
  final placeController = TextEditingController();
  final utcOffsetController = TextEditingController(text: '+05:30');
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  bool loading = true;
  static const rashis = [
    ['मेष','Aries','21 मार्च – 19 अप्रैल','मूंगा','श्री हनुमान जी / भगवान शिव','ॐ हनुमते नमः'],
    ['वृषभ','Taurus','20 अप्रैल – 20 मई','हीरा / ओपल','माँ लक्ष्मी','ॐ श्रीं महालक्ष्म्यै नमः'],
    ['मिथुन','Gemini','21 मई – 20 जून','पन्ना','श्री गणेश जी / भगवान विष्णु','ॐ गं गणपतये नमः'],
    ['कर्क','Cancer','21 जून – 22 जुलाई','मोती','भगवान शिव','ॐ नमः शिवाय'],
    ['सिंह','Leo','23 जुलाई – 22 अगस्त','माणिक','सूर्य देव','ॐ घृणिः सूर्याय नमः'],
    ['कन्या','Virgo','23 अगस्त – 22 सितंबर','पन्ना','श्री गणेश जी','ॐ गं गणपतये नमः'],
    ['तुला','Libra','23 सितंबर – 22 अक्टूबर','हीरा / ओपल','माँ लक्ष्मी','ॐ श्रीं महालक्ष्म्यै नमः'],
    ['वृश्चिक','Scorpio','23 अक्टूबर – 21 नवंबर','मूंगा','भगवान शिव / हनुमान जी','ॐ नमः शिवाय'],
    ['धनु','Sagittarius','22 नवंबर – 21 दिसंबर','पुखराज','भगवान विष्णु','ॐ नमो भगवते वासुदेवाय'],
    ['मकर','Capricorn','22 दिसंबर – 19 जनवरी','नीलम','भगवान शिव / शनिदेव','ॐ नमः शिवाय'],
    ['कुंभ','Aquarius','20 जनवरी – 18 फरवरी','नीलम','भगवान शिव / शनिदेव','ॐ नमः शिवाय'],
    ['मीन','Pisces','19 फरवरी – 20 मार्च','पुखराज','भगवान विष्णु','ॐ नमो भगवते वासुदेवाय'],
  ];
  // Traditional gemstone associations by Vedic Moon sign. These are cultural
  // correspondences, not personalized prescriptions; suitability needs a full
  // chart review and should never be inferred from Moon sign alone.
  static const vedicMoonRashiGems = <String, String>{
    'मेष': 'मूंगा',
    'वृषभ': 'हीरा / ओपल',
    'मिथुन': 'पन्ना',
    'कर्क': 'मोती',
    'सिंह': 'माणिक',
    'कन्या': 'पन्ना',
    'तुला': 'हीरा / ओपल',
    'वृश्चिक': 'मूंगा',
    'धनु': 'पुखराज',
    'मकर': 'नीलम',
    'कुंभ': 'नीलम',
    'मीन': 'पुखराज',
  };
  static const numberGuides = {
    1:['सूर्य देव','ॐ घृणिः सूर्याय नमः'], 2:['भगवान शिव','ॐ नमः शिवाय'],
    3:['भगवान विष्णु / बृहस्पति','ॐ बृं बृहस्पतये नमः'], 4:['माँ दुर्गा','ॐ दुं दुर्गायै नमः'],
    5:['श्री गणेश जी','ॐ गं गणपतये नमः'], 6:['माँ लक्ष्मी','ॐ श्रीं महालक्ष्म्यै नमः'],
    7:['भगवान शिव','ॐ नमः शिवाय'], 8:['शनिदेव','ॐ शं शनैश्चराय नमः'],
    9:['श्री हनुमान जी','ॐ हनुमते नमः'],
  };
  @override
  void initState(){super.initState();_load();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString('profile_birth_date');
    final t=p.getString('profile_birth_time')?.split(':');
    if(raw!=null) dob=DateTime.tryParse(raw);
    if(t!=null&&t.length==2) birthTime=TimeOfDay(hour:int.tryParse(t[0])??0,minute:int.tryParse(t[1])??0);
    placeController.text=p.getString('profile_birth_place')??'';
    utcOffsetController.text=p.getString('profile_utc_offset')??'+05:30';
    latitudeController.text=p.getString('profile_latitude')??'';
    longitudeController.text=p.getString('profile_longitude')??'';
    if(mounted)setState(()=>loading=false);
  }
  Future<void> _save() async {
    final p=await SharedPreferences.getInstance();
    if(dob!=null) await p.setString('profile_birth_date',dob!.toIso8601String());
    if(birthTime!=null) await p.setString('profile_birth_time',birthTime!.hour.toString().padLeft(2,'0')+':'+birthTime!.minute.toString().padLeft(2,'0'));
    await p.setString('profile_birth_place',placeController.text.trim());
    await p.setString('profile_utc_offset',utcOffsetController.text.trim());
    await p.setString('profile_latitude',latitudeController.text.trim());
    await p.setString('profile_longitude',longitudeController.text.trim());
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('जन्म विवरण इसी फोन में सेव हो गया।')));
    if(mounted)setState((){});
  }
  int _reduce(String s){
    var n=s.replaceAll(RegExp(r'[^0-9]'),'').split('').fold<int>(0,(a,b)=>a+int.parse(b));
    while(n>9){n=n.toString().split('').fold<int>(0,(a,b)=>a+int.parse(b));}
    return n;
  }
  int? _offsetMinutes() {
    final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(utcOffsetController.text.trim());
    if (match == null) return null;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3)!);
    if (hours > 14 || minutes > 59 || (hours == 14 && minutes != 0)) return null;
    final value = hours * 60 + minutes;
    return match.group(1) == '-' ? -value : value;
  }
  VedicLunarPosition? _vedicMoonPosition() {
    if (dob == null || birthTime == null) return null;
    final offset = _offsetMinutes();
    if (offset == null) return null;
    final localAsUtc = DateTime.utc(dob!.year, dob!.month, dob!.day, birthTime!.hour, birthTime!.minute);
    final birthUtc = localAsUtc.subtract(Duration(minutes: offset));
    final snapshot = const AstronomyEngine().positionsAtUtc(birthUtc);
    return VedicLunarPosition.fromTropicalMoon(snapshot.moonTropicalLongitude, birthUtc);
  }
  int _mulank(DateTime d)=>_reduce(d.day.toString());
  int _bhagyank(DateTime d)=>_reduce(d.day.toString()+d.month.toString()+d.year.toString());
  int _sunSign(DateTime d){
    final m=d.month,day=d.day;
    if((m==3&&day>=21)||(m==4&&day<=19))return 0;
    if((m==4&&day>=20)||(m==5&&day<=20))return 1;
    if((m==5&&day>=21)||(m==6&&day<=20))return 2;
    if((m==6&&day>=21)||(m==7&&day<=22))return 3;
    if((m==7&&day>=23)||(m==8&&day<=22))return 4;
    if((m==8&&day>=23)||(m==9&&day<=22))return 5;
    if((m==9&&day>=23)||(m==10&&day<=22))return 6;
    if((m==10&&day>=23)||(m==11&&day<=21))return 7;
    if((m==11&&day>=22)||(m==12&&day<=21))return 8;
    if((m==12&&day>=22)||(m==1&&day<=19))return 9;
    if((m==1&&day>=20)||(m==2&&day<=18))return 10;
    return 11;
  }
  Future<void> _pickDate() async {
    final v=await showDatePicker(context:context,initialDate:dob??DateTime(1995,1,1),firstDate:DateTime(1900),lastDate:DateTime.now(),helpText:'जन्मतिथि चुनें');
    if(v!=null)setState(()=>dob=v);
  }
  Future<void> _pickTime() async {
    final v=await showTimePicker(context:context,initialTime:birthTime??const TimeOfDay(hour:6,minute:0));
    if(v!=null)setState(()=>birthTime=v);
  }
  Widget _card(String title,List<Widget> children)=>Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:Color(0xFF754414))),const SizedBox(height:10),...children])));
  Widget _line(String label,String value)=>Padding(padding:const EdgeInsets.only(bottom:9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:TextStyle(fontSize:12,color:Colors.brown.shade500)),const SizedBox(height:3),SelectableText(value,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w600))]));
  @override
  void dispose(){placeController.dispose();utcOffsetController.dispose();latitudeController.dispose();longitudeController.dispose();super.dispose();}
  @override
  Widget build(BuildContext context){
    if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    final d=dob;
    final sign=d==null?null:rashis[_sunSign(d)];
    final mul=d==null?null:_mulank(d);
    final bhag=d==null?null:_bhagyank(d);
    final mg=mul==null?null:numberGuides[mul]!;
    final bg=bhag==null?null:numberGuides[bhag]!;
    final vedicMoon = _vedicMoonPosition();
    return Scaffold(appBar:AppBar(title:const Text('मेरी राशि और अंक ज्योतिष')),body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),gradient:const LinearGradient(colors:[Color(0xFF492A17),Color(0xFF9B5B25)])),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('अपनी जन्म जानकारी भरें',style:TextStyle(color:Color(0xFFFFD98A),fontSize:21,fontWeight:FontWeight.bold)),SizedBox(height:6),Text('जन्मतिथि, सही समय और जन्म स्थान से अपनी ज्योतिष प्रोफ़ाइल तैयार करें।',style:TextStyle(color:Colors.white,height:1.5))])),
      const SizedBox(height:12),
      _card('जन्म विवरण',[
        ListTile(contentPadding:EdgeInsets.zero,title:const Text('जन्मतिथि'),subtitle:Text(d==null?'तारीख चुनें':d.day.toString()+'/'+d.month.toString()+'/'+d.year.toString()),trailing:const Icon(Icons.calendar_month),onTap:_pickDate),
        ListTile(contentPadding:EdgeInsets.zero,title:const Text('जन्म का सही समय'),subtitle:Text(birthTime?.format(context)??'समय चुनें'),trailing:const Icon(Icons.access_time),onTap:_pickTime),
        TextField(controller:placeController,decoration:const InputDecoration(labelText:'जन्म स्थान / शहर',hintText:'जैसे: Deoghar, Jharkhand',prefixIcon:Icon(Icons.location_on_outlined))),
        const SizedBox(height:8),
        TextField(controller:utcOffsetController,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'जन्म स्थान का UTC Offset',hintText:'+05:30',helperText:'भारत के लिए +05:30 • अन्य देशों के लिए उस तारीख का सही UTC offset भरें',prefixIcon:Icon(Icons.public))),
        const SizedBox(height:8),
        TextField(controller:latitudeController,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'अक्षांश (Latitude)',hintText:'जैसे 24.03',helperText:'उत्तर +, दक्षिण −',prefixIcon:Icon(Icons.explore_outlined))),
        const SizedBox(height:8),
        TextField(controller:longitudeController,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'देशांतर (Longitude)',hintText:'जैसे 84.07',helperText:'पूर्व +, पश्चिम −',prefixIcon:Icon(Icons.explore))),

        const SizedBox(height:12),
        SizedBox(width:double.infinity,child:FilledButton(onPressed:_save,style:FilledButton.styleFrom(backgroundColor:const Color(0xFF754414),minimumSize:const Size.fromHeight(48)),child:const Text('जन्म विवरण सेव करें'))),
        const SizedBox(height:10),
        SizedBox(width:double.infinity,child:OutlinedButton.icon(
          onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const KundliPage())),
          icon:const Icon(Icons.grid_view_rounded),
          label:const Text('पूर्ण वैदिक कुंडली खोलें'),
          style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(48)),
        )),

      ]),
      if(d==null) const Text('पहले जन्मतिथि, समय और जन्म स्थान भरें।',style:TextStyle(color:Colors.brown)) else ...[
        _card('अंक ज्योतिष के अनुसार आपका मूलांक: '+mul.toString(),[const Text('जन्म के दिन के अंकों को जोड़कर मूलांक निकाला जाता है.'),_line('पारंपरिक आराध्य देव',mg![0]),_line('मंत्र',mg[1])]),
        _card('अंक ज्योतिष के अनुसार आपका भाग्यांक: '+bhag.toString(),[const Text('पूरी जन्मतिथि के अंकों को जोड़कर भाग्यांक निकाला जाता है.'),_line('पारंपरिक आराध्य देव',bg![0]),_line('मंत्र',bg[1])]),
        _card('जन्मतिथि आधारित पश्चिमी सूर्य-राशि संकेत: '+sign![0]+' ('+sign[1]+')',[_line('तारीख सीमा',sign[2]),_line('पारंपरिक आराध्य देव',sign[4]),_line('मंत्र',sign[5]),_line('पश्चिमी सूर्य-राशि से जुड़ा लोकप्रिय रत्न (वैदिक सलाह नहीं)',sign[3])]),
        if (vedicMoon != null)
          _card('वैदिक चंद्र राशि • लाहिरी (mean)', [
            _line('जन्म चंद्र राशि', vedicMoon.rashi),
            _line('जन्म नक्षत्र', vedicMoon.nakshatra),
            _line('नक्षत्र चरण', vedicMoon.nakshatraPada.toString()),
            _line('निरयण चंद्र longitude', vedicMoon.siderealLongitude.toStringAsFixed(4)+'°'),
            _line('इस चंद्र राशि से जुड़ा पारंपरिक रत्न', vedicMoonRashiGems[vedicMoon.rashi] ?? 'उपलब्ध नहीं'),
            const Text('रत्न संबंध केवल पारंपरिक राशि-आधारित जानकारी है, व्यक्तिगत पहनने की सलाह नहीं। रत्न चुनने से पहले पूरी जन्म-कुंडली, ग्रह-स्वामित्व और दशा का योग्य ज्योतिषी से परीक्षण कराएँ।',style:TextStyle(fontSize:12,height:1.5,color:Colors.brown)),
            const Text('गणना नोट: यह Meeus-आधारित चंद्र स्थिति और लाहिरी mean अयनांश के प्रारंभिक मॉडल पर आधारित है। Nutation correction और स्वतंत्र पंचांग cross-validation अभी बाकी है; राशि-सीमा के निकट परिणाम को अंतिम कुंडली न मानें.',style:TextStyle(fontSize:12,height:1.5,color:Colors.brown)),
          ])
        else
          _card('वैदिक चंद्र राशि • लाहिरी', [const Text('चंद्र राशि निकालने के लिए जन्मतिथि, जन्म का सही समय और सही UTC offset भरें। भारत के लिए +05:30 रखें।',style:TextStyle(height:1.5))]),
        _card('वैदिक कुंडली • गणना की स्थिति',[const Text('लाहिरी mean अयनांश से चंद्र राशि, नक्षत्र और चरण का प्रारंभिक परिणाम ऊपर दिखाया गया है। अभी लग्न, 12 भाव, सभी ग्रहों की स्थिति, दशा और पंचांग शामिल नहीं हैं। पूर्ण कुंडली के लिए जन्म स्थान के coordinates, historical timezone handling, nutation correction और स्वतंत्र ephemeris validation जोड़ना बाकी है.'),const SizedBox(height:8),Text('जन्म स्थान: '+(placeController.text.trim().isEmpty?'नहीं भरा':placeController.text.trim())+' • समय: '+(birthTime?.format(context)??'नहीं भरा')+' • UTC offset: '+utcOffsetController.text.trim())]),
        _card('रत्न और मंत्र के बारे में सावधानी',[const Text('रत्नों और ग्रह-प्रभाव से जुड़े सुझाव पारंपरिक ज्योतिषीय मान्यताएँ हैं, वैज्ञानिक रूप से सिद्ध उपचार या सफलता की गारंटी नहीं। नीलम, पुखराज, मूंगा जैसे महँगे रत्न केवल इस सामान्य जानकारी के आधार पर न पहनें। मंत्र-जाप श्रद्धा और व्यक्तिगत साधना के रूप में करें.')]),
      ],
    ]));
  }
}
