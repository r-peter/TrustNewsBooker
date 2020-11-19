package trustNewsBooker;

import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.Transaction;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;
import com.owlike.genson.Genson;

@Contract(name = "TrustNewsBooker", info = @Info(title = "TrustNewsBooker contract", description = "TrustNewsBooker chaincode", version = "0.0.1-SNAPSHOT"))

public final class TrustNewsBooker implements ContractInterface {

	private final Genson genson = new Genson();

	private enum TrustNewsBookerrErrors {
		TrustNews_NOT_FOUND, TrustNews_ALREADY_EXISTS
	}

	/**
	 * Add some initial properties to the ledger
	 *
	 * @param ctx the transaction context
	 */
	@Transaction()
	public void initLedger(final Context ctx) {
		ChaincodeStub stub = ctx.getStub();
		TrustNews trustNews = new TrustNews("0", "FirstTrustNews", "Admin");
		String trustNewsState = genson.serialize(trustNews);
		stub.putStringState("0", trustNewsState);
	}

	/**
	 * Add new trustNews on the ledger.
	 *
	 * @param ctx     the transaction context
	 * @param id      the key for the new trust news
	 * @param content the content of the trust news
	 * @return the created trust news.
	 */

	@Transaction()
	public TrustNews addTrustNews(final Context ctx, final String id, final String content, final String signature) {

		ChaincodeStub stub = ctx.getStub();

		String trustNewsState = stub.getStringState(id);
		if (!trustNewsState.isEmpty()) {
			String errorMessage = String.format("TrustNews %s already exists", id);
			System.out.println(errorMessage);
			throw new ChaincodeException(errorMessage, TrustNewsBookerrErrors.TrustNews_ALREADY_EXISTS.toString());
		}

		TrustNews trustNews = new TrustNews(id, content, signature);
		trustNewsState = genson.serialize(trustNews);
		stub.putStringState(id, trustNewsState);
		return trustNews;
	}

	/**
	 * Retrieves a trust news based upon trust news Id from the ledger.
	 *
	 * @param ctx the transaction context
	 * @param id  the key
	 * @return the trust news found on the ledger if there was one
	 */

	@Transaction()
	public TrustNews queryTrustNewsById(final Context ctx, final String id) {
		ChaincodeStub stub = ctx.getStub();
		String trustNewsState = stub.getStringState(id);

		if (trustNewsState.isEmpty()) {
			String errorMessage = String.format("TrustNews %s does not exist", id);
			System.out.println(errorMessage);
			throw new ChaincodeException(errorMessage, TrustNewsBookerrErrors.TrustNews_ALREADY_EXISTS.toString());
		}
		TrustNews trustNews = genson.deserialize(trustNewsState, TrustNews.class);
		return trustNews;
	}

	/**
	 * Changes the signature of a trust news on the ledger.
	 *
	 * @param ctx       the transaction context
	 * @param id        the key
	 * @param signature the new signature
	 * @return the updated trust news
	 */
	@Transaction()
	public TrustNews changeTrustNews(final Context ctx, final String id, final String newSignature) {

		ChaincodeStub stub = ctx.getStub();
		String trustNewsState = stub.getStringState(id);

		if (trustNewsState.isEmpty()) {
			String errorMessage = String.format("TrustNews %s does not exist", id);
			System.out.println(errorMessage);
			throw new ChaincodeException(errorMessage, TrustNewsBookerrErrors.TrustNews_NOT_FOUND.toString());
		}

		TrustNews trustNews = genson.deserialize(trustNewsState, TrustNews.class);

		TrustNews newTrustNews = new TrustNews(trustNews.getId(), trustNews.getContent(), newSignature);
		String newTrustNewsState = genson.serialize(newTrustNews);
		stub.putStringState(id, newTrustNewsState);

		return newTrustNews;
	}

}
