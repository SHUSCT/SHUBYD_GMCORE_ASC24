# How to Use OpenVPN to Access the SHU Campus Network via Proxy on Linux

This documentation is a tutorial about using OpenVPN to access the SHU Campus Network via proxy on Linux.

## 1. Install the OpenVPN

```bash
sudo apt install openvpn
```

## 2. Download the configuration file

Visit [上海大学VPN使用说明](vpn.shu.edu.cn) and click the `> Windows/Linux` under the `OpenVPN(推荐使用)`.

Then slide to the bottom of the page and click one of the `【SHU.ovpn】` to download the configuration file.

## 3. Use OpenVPN to run the configuration file

Open the Terminal where you saved your configuration file, and enter: 

```bash
sudo openvpn --config SHU.ovpn
```

Then enter your username (your student ID number) and your password.

💡**Note**: 

- If you don't use `sudo`, it may lead to some unexpected problem (or maybe that's my problem LOL).
- To disconnect, just press `ctrl` + `C`.

## PS: Please correct me if I have made any mistakes.
