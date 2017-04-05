// Benchmark contains a few different attempts to convert a hexadecimal string
// to a list of integers in the fastest way possible.  The tests'
// performance is by compared calling Limits.getCpuTime().
// 
// When this test is run for the first time, execution can be faster and then
// slow down the second or third time it is run.
public class Benchmark {
    // M_HEX_DEC maps hex characters to their represented decimal value.
    // 
    //    M_HEX_DEC.get('a'.charAt(0)) = M_HEX_DEC.get(97) = 10
    //
    public static final Map<Integer, Integer> M_HEX_DEC = new Map<Integer, Integer>{
        48 => 0, 49 => 1, 50 => 2, 51 => 3, 52 => 4, 53 => 5, 54 => 6, 55 => 7,
        56 => 8, 57 => 9, 97 => 10, 98 => 11, 99 => 12, 100 => 13, 101 => 14,
        102 => 15};

    // M_HEXSTR_DEC maps hex characters to their represented decimal value.
    // 
    //    M_HEXSTR_DEC.get('b') = 11
    //
    public static final Map<String, Integer> M_HEXSTR_DEC = new Map<String, Integer>{
        '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6,
        '7' => 7, '8' => 8, '9' => 9, 'a' => 10, 'b' => 11, 'c' => 12, 'd' => 13,
        'e' => 14, 'f' => 15};

    // L_HEX_DEC is maps hex characters hex characters to their represented
    // decimal value. This works as a zero-indexed list which is padded with
    // empty "-1" values to place the result at the right location.
    // 
    //    L_HEX_DEC['2'.charAt(0)] = L_HEX_DEC[50] = 2
    // 
    // This list was generated with Python:
    // 
    //    n = [-1] * (ord('f') + 1);
    //    n[ord('0')] = 0; n[ord('1')] = 1; n[ord('2')] = 2; n[ord('3')] = 3; n[ord('4')] = 4;
    //    n[ord('5')] = 5; n[ord('6')] = 6; n[ord('7')] = 7; n[ord('8')] = 8; n[ord('9')] = 9;
    //    n[ord('a')] = 10; n[ord('b')] = 11; n[ord('c')] = 12;
    //    n[ord('d')] = 13; n[ord('e')] = 14; n[ord('f')] = 15;
    //    print n
    //
    public static final List<Integer> L_HEX_DEC = new List<Integer>{
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7,
        8, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15};

    // STRING_MAX_LENGTH indicates the maximum length a String can have in
    // Salesforce. If the maximum length is exceeded, an fatal StringException
    // is thrown by Salesforce.
    public static final Integer STRING_MAX_LENGTH = 6000000;

    // BLOB_MAX_SIZE indicates the maximum length a Blob can have to never
    // exceed STRING_MAX_LENGTH if converted from raw to hex. This is half the
    // String length because each raw byte occupies two chars in a string. 
    public static final Integer BLOB_MAX_SIZE = STRING_MAX_LENGTH / 2;
    
    public static void Run() {
        Run(10);
    }

    public static void Run(Integer samplesize) {
        String input = '504b030414000800080096bc7a4700000000000000000000000008001000746578742e74787455580c0055ec5756eceb5756262abf22f3c8e40200504b07089a3c22d50500000003000000504b0102150314000800080096bc7a479a3c22d5050000000300000008000c000000000000000040a48100000000746578742e7478745558080055ec5756eceb5756504b05060000000001000100420000004b0000000000';
        List<Integer> expected = new List<Integer>{80, 75, 3, 4, 20, 0, 8, 0, 8, 0, 150, 188, 122, 71, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 16, 0, 116, 101, 120, 116, 46, 116, 120, 116, 85, 88, 12, 0, 85, 236, 87, 86, 236, 235, 87, 86, 38, 42, 191, 34, 243, 200, 228, 2, 0, 80, 75, 7, 8, 154, 60, 34, 213, 5, 0, 0, 0, 3, 0, 0, 0, 80, 75, 1, 2, 21, 3, 20, 0, 8, 0, 8, 0, 150, 188, 122, 71, 154, 60, 34, 213, 5, 0, 0, 0, 3, 0, 0, 0, 8, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 64, 164, 129, 0, 0, 0, 0, 116, 101, 120, 116, 46, 116, 120, 116, 85, 88, 8, 0, 85, 236, 87, 86, 236, 235, 87, 86, 80, 75, 5, 6, 0, 0, 0, 0, 1, 0, 1, 0, 66, 0, 0, 0, 75, 0, 0, 0, 0, 0};

        // Repeat the mock values a few times to get more relevant test results.

        for (Integer i = 0; i < 6; i++) {
            input = input + input;
            expected.addAll(expected);
        }

        // Some possible exceptions to keep in mind:
        //
        //   - System.StringException: String length exceeds maximum: 6000000
        //   - System.StringException: BLOB is not a valid UTF-8 string
        //   - System.LimitException: Apex heap size too large: 8015286
        //   - System.LimitException: Apex CPU time limit exceeded

        Blob data = EncodingUtil.convertFromHex(input);
        if (data.size() > BLOB_MAX_SIZE) {
            throw new BenchmarkException('Blob size exceeds maximum parsable: ' + BLOB_MAX_SIZE);
        }

        // Prepare benchmarks.
        
        Map<String, List<Integer>> deltas = new Map<String, List<Integer>>{
            'Benchmark1A' => new List<Integer>(),
            'Benchmark1B' => new List<Integer>(),
            'Benchmark1C' => new List<Integer>(),
            'Benchmark2A' => new List<Integer>(),
            'Benchmark2B' => new List<Integer>(),
            'Benchmark2C' => new List<Integer>(),
            'Benchmark2D' => new List<Integer>(),
            'Benchmark3A' => new List<Integer>(),
            'Benchmark3B' => new List<Integer>(),
            'Benchmark4A' => new List<Integer>(),
            'Benchmark4B' => new List<Integer>()};
        
        // Assert that each method returns the same list of raw bytes.

        System.assertEquals(expected, Benchmark1A(data));
        System.assertEquals(expected, Benchmark1B(data));
        System.assertEquals(expected, Benchmark1C(data));

        System.assertEquals(expected, Benchmark2A(data));
        System.assertEquals(expected, Benchmark2B(data));
        System.assertEquals(expected, Benchmark2C(data));
        System.assertEquals(expected, Benchmark2D(data));

        System.assertEquals(expected, Benchmark3A(data));
        System.assertEquals(expected, Benchmark3B(data));

        System.assertEquals(expected, Benchmark4A(data));
        System.assertEquals(expected, Benchmark4B(data));

        // Run benchmarks.

        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark1A(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark1A').add(cpuDelta);
        }
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark1B(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark1B').add(cpuDelta);
        }
        
        for (Integer i = 0; i < 1; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark1C(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark1C').add(cpuDelta);
        }

        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark2A(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark2A').add(cpuDelta);
        }
                                        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark2B(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark2B').add(cpuDelta);
        }
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark2C(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark2C').add(cpuDelta);
        }        
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark2D(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark2D').add(cpuDelta);
        }        
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark3A(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark3A').add(cpuDelta);
        } 
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark3B(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark3B').add(cpuDelta);
        }   
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark4A(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark4A').add(cpuDelta);
        }    
        
        for (Integer i = 0; i < samplesize; i++) {
            Integer cpuBefore = Limits.getCpuTime();
            
            List<Integer> actual = Benchmark4B(data);
            
            Integer cpuAfter = Limits.getCpuTime();
            Integer cpuDelta = cpuAfter - cpuBefore;
            deltas.get('Benchmark4B').add(cpuDelta);
        }        

        // Summarize results.

        for (String key : deltas.keySet()) {
            List<Integer> vals = deltas.get(key);
            if (vals.size() < 1) {
                System.debug(key + ': skip');
                continue;
            }
            Integer avg = 0;
            for (Integer n : vals) {
                avg += n;
            }
            avg /= vals.size();
            System.debug(key + ': ' + avg + ' ms avg. ' + vals);
        }
    }
    
    // 1(a) - Lookup from the M_HEX_DEC map.
    //
    // Typical: 176 ms (worse)
    public static List<Integer> Benchmark1A(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {
            bytes.add(M_HEX_DEC.get(chars[i]) * (1 << 4) + M_HEX_DEC.get(chars[i+1]));
        }
        
        return bytes;
    }
    
    // 1(b) - Like 1(a) but lookup from a list.
    //
    // Typical: 110 ms (similar)
    public static List<Integer> Benchmark1B(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {
            bytes.add(L_HEX_DEC[chars[i]] * (1 << 4) + L_HEX_DEC[chars[i+1]]);
        }
        
        return bytes;
    }
    
    // 1(c) - Like 1(a) but instead of iterating over a list from getChars(),
    //        call mid() for each char. Lookup the by string instead of int.
    //
    // Typical: 400ms ms (much worse)
    public static List<Integer> Benchmark1C(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < str.length(); i += 2) {
            bytes.add(M_HEXSTR_DEC.get(str.mid(i, 1)) * (1 << 4) +
                      M_HEXSTR_DEC.get(str.mid(i+1, 1)));
        }
        
        return bytes;
    }
     
    // 2(a) - Convert with the original HexUtil formula which uses the underlying ASCII math.
    //
    //    ((c[0] & 15) + ((c[0] >>> 6) * 9)) << 4 |
    //    ((c[1] & 15) + ((c[1] >>> 6) * 9))
    //
    // Typical: 110 ms (baseline)
    public static List<Integer> Benchmark2A(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {
            bytes.add((((chars[i  ] & 15)+(chars[i  ]>>>6)*9)) << 4 |
                      (((chars[i+1] & 15)+(chars[i+1]>>>6)*9)));
        }
        
        return bytes;
    }    
    
    // 2(b) - Like 2(a) but try a different formula to add the values of c[0] and c[1].
    //
    //    ((c[0] & 15) + ((c[0] >>> 6) * 9)) * 16 +
    //    ((c[1] & 15) + ((c[1] >>> 6) * 9))
    //
    // Typical: 109 ms (similar)
    public static List<Integer> Benchmark2B(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {           
            bytes.add((((chars[i  ] & 15)+(chars[i  ]>>>6)*9)) * 16 +
                      (((chars[i+1] & 15)+(chars[i+1]>>>6)*9)));
        }
        
        return bytes;
    }    

    // 2(c) - Like 2(a) but write to the original list and then truncate its second half.
    //        This is an attempt to allocate less memory.
    //
    // Typical: 132 ms (worse)
    public static List<Integer> Benchmark2C(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        Integer sizeChars = chars.size();
        
        for (Integer i = 0; i < sizeChars; i += 2) {
            chars.set(i/2, (((chars[i  ] & 15)+(chars[i  ]>>>6)*9)) << 4 |
                           (((chars[i+1] & 15)+(chars[i+1]>>>6)*9)));
        }
        
        for (Integer i = sizeChars-1; i >= sizeChars/2; i--) {
            chars.remove(i);
        }
        
        return chars;
    }

    // 2(d) - Like 2(a) but instead of iterating over a list from getChars(),
    //        call charAt() for each position.
    //
    // Typical: 309 ms (much worse)
    public static List<Integer> Benchmark2D(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < str.length(); i += 2) {
            Integer a = str.charAt(i);
            Integer b = str.charAt(i+1);
            bytes.add((((a&15)+(a>>>6)*9)) << 4 |
                      (((b&15)+(b>>>6)*9)));
        }
        
        return bytes;
    }  

    // 3(a) - Use if-conditions to map character to decimal.
    //
    // Typical: 147 ms (worse)
    public static List<Integer> Benchmark3A(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {
            Integer v = 0;

            Integer a = chars[i];
            Integer b = chars[i+1];
            
            if (a == 48) { v = 0 << 4; }
            if (a == 49) { v = 1 << 4; }
            if (a == 50) { v = 2 << 4; }
            if (a == 51) { v = 3 << 4; }
            if (a == 52) { v = 4 << 4; }
            if (a == 53) { v = 5 << 4; }
            if (a == 54) { v = 6 << 4; }
            if (a == 55) { v = 7 << 4; }
            if (a == 56) { v = 8 << 4; }
            if (a == 57) { v = 9 << 4; }
            if (a == 97) { v = 10 << 4; }
            if (a == 98) { v = 11 << 4; }
            if (a == 99) { v = 12 << 4; }
            if (a == 100) { v = 13 << 4; }
            if (a == 101) { v = 14 << 4; }
            if (a == 102) { v = 15 << 4; }

            if (b == 48) { v += 0; }
            if (b == 49) { v += 1; }
            if (b == 50) { v += 2; }
            if (b == 51) { v += 3; }
            if (b == 52) { v += 4; }
            if (b == 53) { v += 5; }
            if (b == 54) { v += 6; }
            if (b == 55) { v += 7; }
            if (b == 56) { v += 8; }
            if (b == 57) { v += 9; }
            if (b == 97) { v += 10; }
            if (b == 98) { v += 11; }
            if (b == 99) { v += 12; }
            if (b == 100) { v += 13; }
            if (b == 101) { v += 14; }
            if (b == 102) { v += 15; }
            
            bytes.add(v);
        }
        
        return bytes;
    }
    
    // 3(b) - Like 3(a) but use if-else-conditions to map character to decimal.
    //
    // Typical: 115 ms (similar)
    public static List<Integer> Benchmark3B(Blob data) {       
        String str = EncodingUtil.convertToHex(data);
        List<Integer> chars = str.getChars();
        List<Integer> bytes = new List<Integer>();
        
        for (Integer i = 0; i < chars.size(); i += 2) {
            Integer v = 0;

            Integer a = chars[i];
            Integer b = chars[i+1];
            
            if (a == 48) { v = 0 << 4; }
            else if (a == 49) { v = 1 << 4; }
            else if (a == 50) { v = 2 << 4; }
            else if (a == 51) { v = 3 << 4; }
            else if (a == 52) { v = 4 << 4; }
            else if (a == 53) { v = 5 << 4; }
            else if (a == 54) { v = 6 << 4; }
            else if (a == 55) { v = 7 << 4; }
            else if (a == 56) { v = 8 << 4; }
            else if (a == 57) { v = 9 << 4; }
            else if (a == 97) { v = 10 << 4; }
            else if (a == 98) { v = 11 << 4; }
            else if (a == 99) { v = 12 << 4; }
            else if (a == 100) { v = 13 << 4; }
            else if (a == 101) { v = 14 << 4; }
            else if (a == 102) { v = 15 << 4; }

            if (b == 48) { v += 0; }
            else if (b == 49) { v += 1; }
            else if (b == 50) { v += 2; }
            else if (b == 51) { v += 3; }
            else if (b == 52) { v += 4; }
            else if (b == 53) { v += 5; }
            else if (b == 54) { v += 6; }
            else if (b == 55) { v += 7; }
            else if (b == 56) { v += 8; }
            else if (b == 57) { v += 9; }
            else if (b == 97) { v += 10; }
            else if (b == 98) { v += 11; }
            else if (b == 99) { v += 12; }
            else if (b == 100) { v += 13; }
            else if (b == 101) { v += 14; }
            else if (b == 102) { v += 15; }

            
            bytes.add(v);
        }
        
        return bytes;
    }
             
    // 4(a) - Use a regular expression to prefix every two characters with the
    //        escape sequence "\u00XX" and then call getChars() to convert it
    //        to a list of byte values.
    //
    //    '504B0304'  ->  '\u0050\u004B\u0003\u0004'  ->  {80, 75, 3, 4}
    //
    // Typical: 6 ms (much better)
    public static List<Integer> Benchmark4A(Blob data) {
        String str = EncodingUtil.convertToHex(data);
        str = str.replaceAll('(..)', '\\\\u00$1');
        return str.getChars();
    }

    // 4(b) - Like 4(a) but more compact.
    //
    // Typical: 6 ms (much better)
    public static List<Integer> Benchmark4B(Blob data) {       
        return EncodingUtil.convertToHex(data).replaceAll('(..)', '\\\\u00$1').getChars();
    }
    
    public class BenchmarkException extends Exception {}
}