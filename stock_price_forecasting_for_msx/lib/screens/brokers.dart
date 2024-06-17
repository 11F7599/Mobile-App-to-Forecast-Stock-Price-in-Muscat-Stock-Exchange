import 'package:flutter/material.dart';
import 'package:stock_price_forecasting_for_msx/widgets/broker_card.dart';

class Brokers extends StatelessWidget {
  const Brokers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_outlined),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text('Menu', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brokers',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //const SizedBox(height: 10),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Licensed Brokerage Companies',
                      style: TextStyle(fontSize: 18,),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/National Bank of Oman.png',
                  brokerName: 'National Bank of Oman',
                  email: 'Brokerage@nbo.om',
                  url: 'http://www.nbo.om',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/CFI Financial.png',
                  brokerName: 'CFI Financial L.L.C',
                  email: 's.amireh@cfifinancial.com',
                  url: 'http://www.cfifinancial.com',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/FINCORP.jpg',
                  brokerName: 'Financial Corporation Co.',
                  email: 'fincorp@fincorp.org',
                  url: 'http://www.fincorp.org',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Horizons Capital Markets.jpeg',
                  brokerName: 'Horizons Capital Markets',
                  email: 'rontoffice@hcmoman.com',
                  url: 'https://hcmoman.com',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Ubhar Capital.jpg',
                  brokerName: 'Ubhar Capital S.A.O.C.',
                  email: 'custody@u-capital.net',
                  url: 'http://www.u-capital.net',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Global Financial Securities.gif',
                  brokerName: 'Global Financial Securities',
                  email: 'info@gfioman.com',
                  url: 'http://www.gfioman.com',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Financial Services.jpeg',
                  brokerName: 'Financial Services',
                  email: 'info@fscoman.net',
                  url: 'https://www.fscoman.net/',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Ahli Bank.jpg',
                  brokerName: 'Ahli Bank',
                  email: 'ABOBS@ahlibank.om',
                  url: 'https://ahlibank.om',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/Vision Securities LLC.jpg',
                  brokerName: 'Vision Securities LLC',
                  email: 'operations@visioncapital.om',
                  url: 'https://visioncapital.om/',
                ),
                const SizedBox(height: 10),
                const BrokerCard(
                  imagePath: 'assets/images/brokers_images/United securities.jpeg',
                  brokerName: 'United securities',
                  email: 'info@usoman.com',
                  url: 'http://www.usoman.com',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
