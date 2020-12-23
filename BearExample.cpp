#include <comdef.h>
#include <iostream>
#include <Hstring.h>
GUID CLSID_XboxService ={ 0x5b3e6773,0x3a99,0x4a3d,{0x80,0x96,0x77,0x65,0xdd,0x11,0x78,0x5c} };


struct Struct_2 {
	int64_t Member0;
	int64_t Member4;
};

struct Struct_0 {
	HSTRING Member0;
	HSTRING Member8;
	HSTRING Member10;
	HSTRING Member18;
	struct Struct_2 Member20;
	int64_t Member28;
	int8_t Member30;
	int8_t Member31;
};


class __declspec(uuid("4d40ca7e-d22e-4b06-abbc-4defecf695d8")) IXblGameSaveProviderEnumerator : public IUnknown {
public:
	virtual HRESULT __stdcall GetItems(int64_t p0, int64_t p1, struct Struct_0* p2, int64_t* p3)=0;
	virtual HRESULT __stdcall GetItemCount(int64_t* p0)=0;
	virtual HRESULT __stdcall DeleteLocalData(HSTRING p0, HSTRING p1)=0;
	virtual HRESULT __stdcall DeleteLocalAndCloudData(HSTRING p0, HSTRING p1)=0;
};
_COM_SMARTPTR_TYPEDEF(IXblGameSaveProviderEnumerator, __uuidof(IXblGameSaveProviderEnumerator));
class CoInit
{
public:
	CoInit() {
		CoInitialize(nullptr);
	}

	~CoInit() {
		CoUninitialize();
	}
};

void ThrowOnError(HRESULT hr)
{
	if (hr != 0)
	{
		throw _com_error(hr);
	}
}

int wmain(int argc, wchar_t** argv)
{
	CoInit coinit;
	try
	{
		IXblGameSaveProviderEnumeratorPtr xboxservice;
		HRESULT hr = CoCreateInstance(CLSID_XboxService, nullptr, CLSCTX_LOCAL_SERVER, IID_PPV_ARGS(&xboxservice));
		if (FAILED(hr)) { wprintf_s(L"HRESULT: 0x%X\n", hr); }
		DWORD authn_svc;
		DWORD authz_svc;
		LPOLESTR principal_name;
		DWORD authn_level;
		DWORD imp_level;
		RPC_AUTH_IDENTITY_HANDLE identity;
		DWORD capabilities;
		ThrowOnError(CoQueryProxyBlanket(xboxservice, &authn_svc, &authz_svc, &principal_name, &authn_level, &imp_level, &identity, &capabilities));
		ThrowOnError(CoSetProxyBlanket(xboxservice, authn_svc, authz_svc, principal_name, authn_level, RPC_C_IMP_LEVEL_IMPERSONATE, identity, capabilities));

		//I can't be bothered, you can fix this code yourself. It will trigger the GetItems function from the write-up, but will throw an error on enumerate()
		//Anyway, just providing this code as a template for you to copy paste to other COM stuff. This code was originally copy pasted from a James Forshaw PoC, credits where credits are due.
		Struct_0 blah[5];
		int64_t blah2 =0;
		ThrowOnError(xboxservice->GetItems(1, 5, blah,&blah2));
		

	}
	catch (const _com_error& error)
	{
		printf("%ls\n", error.ErrorMessage());
		printf("%08X\n", error.Error());
	}
	return 0;
}
