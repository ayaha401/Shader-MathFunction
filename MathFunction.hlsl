#ifndef MATH_FUNCTION
#define MATH_FUNCTION

// aからbの間の値のtを0~1にマッピングする
#define linearStep(a, b, t) saturate(((t)-(a))/((b)-(a)))

// カメラの前方向のベクトルを取得
float3 getCameraForwardDir()
{
    return normalize(-UNITY_MATRIX_V[2].xyz);
}

// オブジェクトのスケールを取得
float3 getObjectScale()
{
    float3 scale = float3(
                            length(float3(unity_ObjectToWorld[0].x , unity_ObjectToWorld[1].x , unity_ObjectToWorld[2].x)),
	                        length(float3(unity_ObjectToWorld[0].y , unity_ObjectToWorld[1].y , unity_ObjectToWorld[2].y)),
	                        length(float3(unity_ObjectToWorld[0].z , unity_ObjectToWorld[1].z , unity_ObjectToWorld[2].z))
                        );
    return scale;
}

// オブジェクトのポジションを取得
float3 getObjecttWorldPosition()
{
    return transpose(UNITY_MATRIX_M)[3].xyz;
}

// positionOSをワールド空間に変換する
// UnityのSpaceTransforms.TransformObjectToWorldと同じ
float3 getWorldPos(float3 positionOS)
{
    return mul(GetObjectToWorldMatrix(), float4(positionOS, 1.0)).xyz;
}

// lerpの逆関数
// aとbの値が等しい場合、0で割り算が発生する可能性がある
float inverseLerp(float a, float b, float t)
{
    return (t - a) / (b - a);
}

// 距離の二乗を計算する
// Distanceより早く計算できる
float distSquared(float2 a, float2 b)
{
    float2 c = a - b;
    return dot(c, c);
}

// 値を0~1にclampする
float remap(float val, float2 inMinMax, float2 outMinMax)
{
    return clamp(outMinMax.x + (val - inMinMax.x) * (outMinMax.y - outMinMax.x) / (inMinMax.y - inMinMax.x), outMinMax.x, outMinMax.y);
}

// 回転
float2x2 rot(float a)
{
    return float2x2(cos(a), sin(a), -sin(a), cos(a));
}

// 極座標
float2 polar(float2 uv, float2 center = float2(0.0, 0.0), float radialScale = 1.0, float lengthScale = 1.0)
{
    float2 delta = uv - center;
    float radius = length(delta) * 2.0 * radialScale;
    float angle = atan2(delta.x, delta.y) * rcp(6.28) * lengthScale; // rcp(6.28) = 1.0 / 6.28
    return float2(radius, angle);
}

// 繰り返す
float2 repeat(float2 p, float n)
{
    return abs(fmod(p, n)) - n * 0.5;
}

// 繰り返す
float3 repeat(float3 p, float n)
{
    return abs(fmod(p, n)) - n * 0.5;
}

// -1～1の曲線を返す
// GLSLのtanh
// x * nで曲線のsmoothnessを変更できる。n>1で急に、n<1でリニアになる
float tanh(float x)
{
    float exp2x = exp(2.0 * x);
    return (exp2x - 1.0) / (exp2x + 1.0);
}

// -1～1の曲線を返す
// GLSLではtanhより速い(たぶん)(https://x.com/XorDev/status/1928598796188955019)
// HLSLではexp使ったtanhがあるのでこれを使用したほうが早いかは不明
float fastTanh(float x)
{
    return x * rsqrt(1.0 + x * x);
}

// 量子化する
// valueをstepの数で分割する
float quantize(float value, float step)
{
    step = max(step, 0.0001);
    return floor(value * step) / step;
}

// UV座標をピクセル化する
// stepは分割数
float2 pixelate(float2 uv, float step)
{
    uv.x = quantize(uv.x, step);
    uv.y = quantize(uv.y, step);

    return uv;
}

// sinを使用した0~1までを繰り返すTime
float sinTime()
{
    return abs(sin(_Time.y));
}

// cosを使用した0~1までを繰り返すTime
float cosTime()
{
    return abs(cos(_Time.y));
}

//===================================//
// ミンコフスキー距離を計算する        //
// m =  1        : manhattanDistance //
// m =  2        : euclideanDistance //
// m =  infinity : chebyshevDistance //
//===================================//
float minkowskiDistance(float2 uv, float m)
{
    float2 d1=pow(abs(float2(uv.x, uv.y)),(float2)m);
    return pow((d1.x+d1.y),1.0 / m);
}

// ディザ抜きに必要な4x4の閾値
// https://docs.unity3d.com/ja/Packages/com.unity.shadergraph@10.0/manual/Dither-Node.html
static const float DITHER_THRESHOLDS[16] =
{
    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
    13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
    16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
};

// https://docs.unity3d.com/ja/Packages/com.unity.shadergraph@10.0/manual/Dither-Node.html
// value : Ditherの強度
// screenPosition : screenPosition
float dither(float value, float2 screenPosition)
{
    float2 uv = screenPosition.xy * _ScreenParams.xy;
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    return value - DITHER_THRESHOLDS[index];
}

// 法線を合成する
// https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Normal-Blend-Node.html
float3 blend_RNM(float3 n1, float3 n2)
{
    float3 t = n1 + float3(0, 0, 1);
    float3 u = n2 * float3(-1, -1, 1);
    float3 r = normalize(t * dot(t, u) - u * t.z);
    return r;
}

#endif
